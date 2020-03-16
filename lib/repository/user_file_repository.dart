import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/src/base_client.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/user_file_db.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/sync_response.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';

class UserFileRepository extends DataRepository<UserFile> {
  final UserFileDb userFileDb;
  final int userId;
  final String authToken;
  final FileStorage fileStorage;

  UserFileRepository({
    @required BaseClient httpClient,
    @required String baseUrl,
    @required this.userFileDb,
    @required this.fileStorage,
    @required this.userId,
    @required this.authToken,
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
    userFileDb.insertAndAddDirty(userFiles);
  }

  @override
  Future<bool> synchronize() async {
    // Get all dirty user files
    final dirtyFiles = await userFileDb.getAllDirty();
    if (dirtyFiles.isNotEmpty) {
      final lastRevision = await userFileDb.getLastRevision();
      // First save actual files to backend
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
      // Then post user files to backend
      await postUserFiles(dirtyFiles, lastRevision);
    }
    return true;
  }

  Future<Iterable<DbUserFile>> _fetchUserFiles(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/storage/items?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => DbUserFile.fromJson(e));
  }

  Future<List<SyncResponse>> postUserFiles(
    Iterable<DbUserFile> userFiles,
    int latestRevision,
  ) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/storage/items/$latestRevision',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(userFiles.toList()),
    );

    if (response.statusCode == 200) {
      final l = json.decode(response.body);
      return UnmodifiableListView(
          l?.whereType<Map<String, dynamic>>()?.map(SyncResponse.fromJson) ??
              []);
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

      var url = Uri.parse('$baseUrl/api/v1/data/$userId/storage/files');
      var request = MultipartRequest('POST', url)
        ..files.add(MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'test.jpg',
        ))
        ..headers['X-Auth-Token'] = authToken
        ..fields.addAll({
          'sha1': sha1,
        });
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
      } else {
        return false;
      }
    }
    return true;
  }
}
