import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

class UserFileRepository extends DataRepository<UserFile> {
  final UserFileDb userFileDb;
  final FileStorage fileStorage;
  final MultipartRequestBuilder multipartRequestBuilder;

  UserFileRepository({
    @required String baseUrl,
    @required BaseClient client,
    @required String authToken,
    @required int userId,
    @required this.userFileDb,
    @required this.fileStorage,
    @required this.multipartRequestBuilder,
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

  Future<bool> allFilesLoaded() => userFileDb.allFilesLoaded();

  Future<Iterable<UserFile>> getAllLoadedFiles() =>
      userFileDb.getAllLoadedFiles();

  @override
  Future<Iterable<UserFile>> load() async {
    await fetchIntoDatabaseSynchronized();
    await getAndStoreFileData();
    return db.getAll();
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      await fetchIntoDatabase();
      final dirtyFiles = await db.getAllDirty();
      if (dirtyFiles.isEmpty) return true;
      for (var dirtyFile in dirtyFiles.map((dirty) => dirty.model)) {
        final file = fileStorage.getFile(dirtyFile.id);
        final postFileSuccess = await postFileData(
          file,
          dirtyFile.sha1,
          dirtyFile.contentType,
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
    await getAndStoreFileData();
    await db.insert(fetchedUserFiles);
  }

  Future<Iterable<DataRevisionUpdate>> _postUserFiles(
    Iterable<DbModel<UserFile>> userFiles,
    int latestRevision,
  ) async {
    final response = await client.post(
      '$baseUrl/api/v1/data/$userId/storage/items/$latestRevision',
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
      errors.forEach((error) {
        if (error.code == ErrorCodes.WRONG_REVISION) {
          throw WrongRevisionException();
        } else {
          log.warning('Unhandled error code: $error');
        }
      });
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException([response.statusCode]);
  }

  Future<bool> postFileData(
    File file,
    String sha1,
    String contentType,
  ) async {
    try {
      final bytes = await file.readAsBytes();

      final uri = Uri.parse('$baseUrl/api/v1/data/$userId/storage/files');
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

  Future<void> getAndStoreFileData({int limit}) async {
    try {
      final missingFiles = await userFileDb.getMissingFiles(limit: limit);
      log.fine('${missingFiles.length} missing files to fetch');
      for (final userFile in missingFiles) {
        if (userFile.isImage) {
          await handleImageFile(userFile);
        } else {
          await handleNonImage(userFile);
        }
      }
    } catch (e, stackTrace) {
      log.severe('Exception when getting and storing file data', e, stackTrace);
    }
  }

  Future<Response> getImageThumb(String id, int size) {
    return client.get(
      imageThumbIdUrl(
        baseUrl: baseUrl,
        userId: userId,
        imageFileId: id,
        size: size,
      ),
      headers: authHeader(authToken),
    );
  }

  Future<void> handleNonImage(UserFile userFile) async {
    final originalFileResponse = await client.get(
      fileIdUrl(baseUrl, userId, userFile.id),
      headers: authHeader(authToken),
    );
    if (originalFileResponse.statusCode == 200) {
      await fileStorage.storeFile(originalFileResponse.bodyBytes, userFile.id);
      await userFileDb.setFileLoadedForId(userFile.id);
    } else {
      throw UnavailableException([originalFileResponse.statusCode]);
    }
  }

  Future<void> handleImageFile(UserFile userFile) async {
    final originalFileResponse = client.get(
      fileIdUrl(baseUrl, userId, userFile.id),
      headers: authHeader(authToken),
    );
    final thumbResponse = getImageThumb(userFile.id, ImageThumb.THUMB_SIZE);
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
