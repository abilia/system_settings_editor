import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/src/base_client.dart';
import 'package:meta/meta.dart';
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
    try {
      final fetchedUserFiles =
          await _fetchUserFiles(await userFileDb.getLastRevision());
      await userFileDb.insert(fetchedUserFiles);
      await getAndStoreFileData(fetchedUserFiles);
    } catch (e) {
      print('Error when loading $e');
    }
    return userFileDb.getAllNonDeleted();
  }

  @override
  Future<void> save(Iterable<UserFile> userFiles) async {
    return userFileDb.insertAndAddDirty(userFiles);
  }

  @override
  Future<bool> synchronize() async {
    final dirtyFiles = await userFileDb.getAllDirty();
    if (dirtyFiles.isNotEmpty) {
      final lastRevision = await userFileDb.getLastRevision();
      for (var dirtyFile in dirtyFiles) {
        final file = await fileStorage.getFile(dirtyFile.userFile.id);
        final postFileSuccess = await postFileData(
          file,
          dirtyFile.userFile.sha1,
          dirtyFile.userFile.contentType,
        );
        if (!postFileSuccess) {
          return false;
        }
      }
      try {
        final syncResponses = await postUserFiles(dirtyFiles, lastRevision);
        await _handleSuccessfulSync(syncResponses, dirtyFiles);
      } on WrongRevisionException catch (_) {
        print('Wrong revision when posting user files');
        await _handleFailedSync();
        return false;
      } catch (e) {
        print('Cannot post user files to backend $e');
        return false;
      }
    }
    return true;
  }

  Future<void> _handleSuccessfulSync(
      List<SyncResponse> syncResponses, Iterable<DbUserFile> dirtyFiles) async {
    final toUpdate = syncResponses.map((response) async {
      final fileBeforeSync =
          dirtyFiles.firstWhere((file) => file.userFile.id == response.id);
      final currentFile = await userFileDb.getById(response.id);
      return currentFile.copyWith(
          revision: response.newRevision,
          dirty: currentFile.dirty - fileBeforeSync.dirty);
    });
    await userFileDb.insert(await Future.wait(toUpdate));
  }

  Future<void> _handleFailedSync() async {
    final latestRevision = await userFileDb.getLastRevision();
    final fetchedUserFiles = await _fetchUserFiles(latestRevision);
    await getAndStoreFileData(fetchedUserFiles);
    await userFileDb.insert(fetchedUserFiles);
  }

  Future<Iterable<DbUserFile>> _fetchUserFiles(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/storage/items?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => DbUserFile.fromJson(e));
  }

  Future<Iterable<SyncResponse>> postUserFiles(
    Iterable<DbUserFile> userFiles,
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

  Future<bool> getAndStoreFileData(Iterable<DbUserFile> dbUserFiles) async {
    for (final dbUserFile in dbUserFiles) {
      final fileResponse = await httpClient.get(
        imageIdUrl(baseUrl, userId, dbUserFile.userFile.id),
        headers: authHeader(authToken),
      );
      if (fileResponse.statusCode == 200) {
        await fileStorage.storeFile(
            fileResponse.bodyBytes, dbUserFile.userFile.id);
        print('File ${dbUserFile.userFile.id} downloaded and stored');
      } else {
        return false;
      }
    }
    return true;
  }
}
