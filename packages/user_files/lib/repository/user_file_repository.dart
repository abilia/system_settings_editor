import 'dart:convert';
import 'dart:io';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:collection/collection.dart';
import 'package:file_storage/file_storage.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';
import 'package:synchronized/extension.dart';
import 'package:user_files/user_files.dart';
import 'package:utils/utils.dart';

class UserFileRepository extends DataRepository<UserFile> {
  final LoginDb loginDb;
  final UserFileDb userFileDb;
  final FileStorage fileStorage;
  final MultipartRequestBuilder multipartRequestBuilder;

  UserFileRepository({
    required super.baseUrlDb,
    required super.client,
    required super.userId,
    required this.userFileDb,
    required this.loginDb,
    required this.fileStorage,
    required this.multipartRequestBuilder,
  }) : super(
          path: 'storage/items',
          db: userFileDb,
          fromJsonToDataModel: DbUserFile.fromJson,
          log: Logger((UserFileRepository).toString()),
        );

  Future<Iterable<UserFile>> getAllLoadedFiles() =>
      userFileDb.getAllLoadedFiles();

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final didFetchData = await fetchIntoDatabase();
      final dirtyFiles = await db.getAllDirty();
      if (dirtyFiles.isEmpty) return didFetchData;
      for (var dirtyFile in dirtyFiles.map((dirty) => dirty.model)) {
        final file = fileStorage.getFile(dirtyFile.id);
        final postFileSuccess = await _postFileData(
          file,
          dirtyFile.sha1,
        );
        if (!postFileSuccess) {
          throw SyncFailedException();
        }
      }

      try {
        final lastRevision = await db.getLastRevision();
        final syncResponses = await _postUserFiles(dirtyFiles, lastRevision);
        await handleSuccessfulSync(syncResponses, dirtyFiles);
        return didFetchData;
      } on WrongRevisionException catch (e) {
        log.info('Wrong revision when posting user files');
        await _handleFailedSync();
        throw SyncFailedException(e);
      } on Exception catch (e) {
        log.warning('Cannot post user files to backend', e);
        throw SyncFailedException(e);
      }
    });
  }

  Future<void> _handleFailedSync() async {
    final latestRevision = await db.getLastRevision();
    final fetchedUserFiles = await fetchData(latestRevision);
    await downloadUserFiles();
    await db.insert(fetchedUserFiles);
  }

  Future<Iterable<DataRevisionUpdate>> _postUserFiles(
    Iterable<DbModel<UserFile>> userFiles,
    int latestRevision,
  ) async {
    final response = await client.post(
      '$baseUrl/api/v1/data/$userId/storage/items/$latestRevision'.toUri(),
      headers: jsonHeader,
      body: jsonEncode(userFiles.toList()),
    );

    if (response.statusCode == 200) {
      final syncResponseJson = response.json() as List;
      return syncResponseJson
          .map((r) => DataRevisionUpdate.fromJson(r))
          .toList();
    } else if (response.statusCode == 400) {
      final errorResponse = response.json();
      final errors = (errorResponse['errors'] as List)
          .map((r) => ResponseError.fromJson(r));
      for (final error in errors) {
        if (error.code == ErrorCodes.wrongRevision) {
          throw WrongRevisionException();
        } else {
          log.warning('Unhandled error code: $error');
        }
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException([response.statusCode]);
  }

  Future<bool> _postFileData(
    File file,
    String sha1,
  ) async {
    try {
      final bytes = await file.readAsBytes();

      final uri = '$baseUrl/api/v1/data/$userId/storage/files'.toUri();
      final request = multipartRequestBuilder.generateFileMultipartRequest(
        uri: uri,
        bytes: bytes,
        authToken: loginDb.getToken() ?? '',
        sha1: sha1,
      );
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        return true;
      } else {
        final response = await Response.fromStream(streamedResponse);
        log.warning(
            'Could not save file to backend ${streamedResponse.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      log.severe('Could not save file to backend', e);
      return false;
    }
  }

  Future<bool> allDownloaded() async =>
      (await userFileDb.getMissingFiles(limit: 1)).isEmpty;

  Future<Iterable<UserFile>> downloadUserFiles({int? limit}) async {
    final missingFiles = await userFileDb.getMissingFiles(limit: limit);
    log.fine('${missingFiles.length} missing files to fetch');
    final fetchedFiles = await Future.wait(
      missingFiles.map(
        (userFile) async {
          try {
            if (userFile.isImage) {
              await _handleImageFile(userFile);
            } else {
              await _handleNonImage(userFile);
            }
            return userFile.setLoaded();
          } catch (e) {
            log.severe('Exception when getting and storing user file', e);
            return null;
          }
        },
      ),
    );
    return fetchedFiles.whereNotNull();
  }

  Future<Response> _getImageThumb(String id, int size) {
    return client.get(
      imageThumbIdUrl(
        baseUrl: baseUrl,
        userId: userId,
        imageFileId: id,
        size: size,
      ).toUri(),
    );
  }

  Future<void> _handleNonImage(UserFile userFile) async {
    final originalFileResponse = await client.get(
      fileIdUrl(baseUrl, userId, userFile.id).toUri(),
    );
    if (originalFileResponse.statusCode == 200) {
      await fileStorage.storeFile(originalFileResponse.bodyBytes, userFile.id);
      await userFileDb.setFileLoadedForId(userFile.id);
    } else {
      throw UnavailableException([originalFileResponse.statusCode]);
    }
  }

  Future<void> _handleImageFile(UserFile userFile) async {
    final originalFileResponse = client.get(
      fileIdUrl(baseUrl, userId, userFile.id).toUri(),
    );
    final thumbResponse = _getImageThumb(userFile.id, ImageThumb.thumbSize);
    final responses = await Future.wait([
      originalFileResponse,
      thumbResponse,
    ]);
    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      log.fine('Got file with id: ${userFile.id} successfully');
      await Future.wait([
        fileStorage.storeFile(responses[0].bodyBytes, userFile.id),
        fileStorage.storeImageThumb(
            responses[1].bodyBytes, ImageThumb(id: userFile.id)),
      ]);
      await userFileDb.setFileLoadedForId(userFile.id);
    } else {
      log.severe('Could not get image files for userFile: $userFile');
      throw UnavailableException(responses.map((e) => e.statusCode).toList());
    }
  }
}
