import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:synchronized/extension.dart';
import 'package:collection/collection.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

class UserFileRepository extends DataRepository<UserFile> {
  final UserFileDb userFileDb;
  final FileStorage fileStorage;
  final MultipartRequestBuilder multipartRequestBuilder;

  UserFileRepository({
    required String baseUrl,
    required BaseClient client,
    required String authToken,
    required int userId,
    required this.userFileDb,
    required this.fileStorage,
    required this.multipartRequestBuilder,
  }) : super(
          client: client,
          baseUrl: baseUrl,
          path: 'storage/items',
          authToken: authToken,
          userId: userId,
          db: userFileDb,
          fromJsonToDataModel: DbUserFile.fromJson,
          log: Logger((UserFileRepository).toString()),
        );

  Future<Iterable<UserFile>> getAllLoadedFiles() =>
      userFileDb.getAllLoadedFiles();

  @override
  Future<Iterable<UserFile>> load() async {
    await fetchIntoDatabaseSynchronized();
    await downloadUserFiles();
    return userFileDb.getAllLoadedFiles();
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      await fetchIntoDatabase();
      final dirtyFiles = await db.getAllDirty();
      if (dirtyFiles.isEmpty) return true;
      for (var dirtyFile in dirtyFiles.map((dirty) => dirty.model)) {
        final file = fileStorage.getFile(dirtyFile.id);
        final postFileSuccess = await _postFileData(
          file,
          dirtyFile.sha1,
        );
        if (!postFileSuccess) return false;
      }

      try {
        final lastRevision = await db.getLastRevision();
        final syncResponses = await _postUserFiles(dirtyFiles, lastRevision);
        await handleSuccessfullSync(syncResponses, dirtyFiles);
        return true;
      } on WrongRevisionException catch (_) {
        log.info('Wrong revision when posting user files');
        await _handleFailedSync();
      } catch (e) {
        log.warning('Cannot post user files to backend', e);
      }
      return false;
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
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(userFiles.toList()),
    );

    if (response.statusCode == 200) {
      final syncResponseJson = json.decode(response.body) as List;
      return syncResponseJson
          .map((r) => DataRevisionUpdate.fromJson(r))
          .toList();
    } else if (response.statusCode == 400) {
      final errorResponse = json.decode(response.body);
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
        authToken: authToken,
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
      headers: authHeader(authToken),
    );
  }

  Future<void> _handleNonImage(UserFile userFile) async {
    final originalFileResponse = await client.get(
      fileIdUrl(baseUrl, userId, userFile.id).toUri(),
      headers: authHeader(authToken),
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
      headers: authHeader(authToken),
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
