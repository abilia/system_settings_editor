import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/src/base_client.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/user_file_db.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';

class UserFileRepository extends DataRepository<UserFile> {
  final UserFileDb userFileDb;
  final int userId;
  final String authToken;
  final FileStorage fileStorage;
  final MultipartRequestBuilder multipartRequestBuilder;

  UserFileRepository({
    @required BaseClient httpClient,
    @required String baseUrl,
    @required this.userFileDb,
    @required this.fileStorage,
    @required this.userId,
    @required this.authToken,
    @required this.multipartRequestBuilder,
  }) : super(httpClient, baseUrl);

  @override
  Future<Iterable<UserFile>> load() async {
    return synchronized(() async {
      try {
        final fetchedUserFiles =
            await _fetchUserFiles(await userFileDb.getLastRevision());
        await userFileDb.insert(fetchedUserFiles);
        await getAndStoreFileData();
      } catch (e) {
        print('Error when loading user files $e');
      }
      return userFileDb.getAllNonDeleted();
    });
  }

  @override
  Future<void> save(Iterable<UserFile> userFiles) async {
    return synchronized(() async {
      return userFileDb.insertAndAddDirty(userFiles);
    });
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtyFiles = await userFileDb.getAllDirty();
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
        final lastRevision = await userFileDb.getLastRevision();
        final syncResponses = await _postUserFiles(dirtyFiles, lastRevision);
        await _handleSuccessfulSync(syncResponses, dirtyFiles);
        return true;
      } on WrongRevisionException catch (_) {
        print('Wrong revision when posting user files');
        await _handleFailedSync();
      } catch (e) {
        print('Cannot post user files to backend $e');
      }
      return false;
    });
  }

  Future<void> _handleSuccessfulSync(List<SyncResponse> syncResponses,
      Iterable<DbModel<UserFile>> dirtyFiles) async {
    final toUpdate = syncResponses.map((response) async {
      final fileBeforeSync =
          dirtyFiles.firstWhere((file) => file.model.id == response.id);
      final currentFile = await userFileDb.getById(response.id);
      final dirtyDiff = currentFile.dirty - fileBeforeSync.dirty;
      return currentFile.copyWith(
        revision: response.newRevision,
        dirty: max(dirtyDiff,
            0), // The activity might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await userFileDb.insert(await Future.wait(toUpdate));
  }

  Future<void> _handleFailedSync() async {
    final latestRevision = await userFileDb.getLastRevision();
    final fetchedUserFiles = await _fetchUserFiles(latestRevision);
    await getAndStoreFileData();
    await userFileDb.insert(fetchedUserFiles);
  }

  Future<Iterable<DbUserFile>> _fetchUserFiles(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/storage/items?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => DbUserFile.fromJson(e));
  }

  Future<Iterable<SyncResponse>> _postUserFiles(
    Iterable<DbModel<UserFile>> userFiles,
    int latestRevision,
  ) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/storage/items/$latestRevision',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(userFiles.toList()),
    );

    if (response.statusCode == 200) {
      final syncResponseJson = json.decode(response.body) as List;
      return syncResponseJson.map((r) => SyncResponse.fromJson(r)).toList();
    } else if (response.statusCode == 400) {
      final errorResponse = json.decode(response.body);
      final errors = (errorResponse['errors'] as List)
          .map((r) => ResponseError.fromJson(r));
      errors.forEach((error) {
        if (error.code == ErrorCodes.WRONG_REVISION) {
          throw WrongRevisionException();
        } else {
          print('Unhandled error code: $error');
        }
      });
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException();
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
        print(
            'Could not save file to backend ${streamedResponse.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Could not save file to backend $e');
      return false;
    }
  }

  Future<bool> getAndStoreFileData() async {
    final missingFiles = await userFileDb.getAllWithMissingFiles();
    try {
      for (final userFile in missingFiles) {
        if (userFile.isImage) {
          await handleImageFile(userFile);
        } else {
          await handleNonImage(userFile);
        }
      }
    } catch (e) {
      print('Exception when getting and storing file data $e');
    }
    return true;
  }

  Future<Response> getImageThumb(String id, int size) {
    return httpClient.get(
      imageThumbUrl(
        baseUrl: baseUrl,
        userId: userId,
        imageFileId: id,
        size: size,
      ),
      headers: authHeader(authToken),
    );
  }

  Future<void> handleNonImage(UserFile userFile) async {
    final originalFileResponse = await httpClient.get(
      fileIdUrl(baseUrl, userId, userFile.id),
      headers: authHeader(authToken),
    );
    if (originalFileResponse.statusCode == 200) {
      await fileStorage.storeFile(originalFileResponse.bodyBytes, userFile.id);
      await userFileDb.setFileLoadedForId(userFile.id);
    } else {
      throw UnavailableException();
    }
  }

  Future<void> handleImageFile(UserFile userFile) async {
    final originalFileResponse = httpClient.get(
      fileIdUrl(baseUrl, userId, userFile.id),
      headers: authHeader(authToken),
    );
    final thumbResponse = getImageThumb(userFile.id, ImageThumb.THUMB_SIZE);
    final List<Response> responses = await Future.wait([
      originalFileResponse,
      thumbResponse,
    ]);
    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      await Future.wait([
        fileStorage.storeFile(responses[0].bodyBytes, userFile.id),
        fileStorage.storeImageThumb(
            responses[1].bodyBytes, ImageThumb(id: userFile.id)),
      ]);
      await userFileDb.setFileLoadedForId(userFile.id);
    } else {
      throw UnavailableException();
    }
  }
}
