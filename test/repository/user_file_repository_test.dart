import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/fakes/fake_user_files.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../mocks.dart';

void main() {
  group('User file repository tests', () {
    final mockUserFileDb = MockUserFileDb();
    final baseUrl = 'url';
    final mockFileStorage = MockFileStorage();
    final mockClient = MockedClient();
    final mockMultiRequestBuilder = MockMultipartRequestBuilder();
    final userId = 1;
    final userFileRepository = UserFileRepository(
      authToken: Fakes.token,
      baseUrl: baseUrl,
      fileStorage: mockFileStorage,
      httpClient: mockClient,
      userFileDb: mockUserFileDb,
      userId: userId,
      multipartRequestBuilder: mockMultiRequestBuilder,
    );
    test('Save saves to db', () async {
      final userFile1 = FakeUserFile.createNew(id: 'fakeId1');
      await userFileRepository.save([userFile1]);
      verify(mockUserFileDb.insertAndAddDirty([userFile1]));
    });

    test('Load saves to db and stores to file storage', () async {
      // Arrange
      final revision = 99;
      when(mockUserFileDb.getLastRevision())
          .thenAnswer((_) => Future.value(revision));
      final fileId = 'id';

      final userFilesJson = '''
          [
            {
              "id": "$fileId",
              "revision": $revision,
              "contentType": "contentType",
              "sha1Hex": "sha1",
              "md5Hex": "md5",
              "path": "path",
              "size": 1
            }
          ]
          ''';

      when(
        mockClient.get(
          '$baseUrl/api/v1/data/$userId/storage/items?revision=$revision',
          headers: authHeader(Fakes.token),
        ),
      ).thenAnswer(
        (_) => Future.value(
          Response(
            userFilesJson,
            200,
          ),
        ),
      );
      final expectedFiles = (json.decode(userFilesJson) as List)
          .map((l) => DbUserFile.fromJson(l))
          .toList();

      when(
        mockClient.get(
          fileIdUrl(baseUrl, userId, fileId),
          headers: authHeader(Fakes.token),
        ),
      ).thenAnswer(
        (_) => Future.value(
          Response(
            FakeUserFile.ONE_PIXEL_PNG,
            200,
          ),
        ),
      );

      // Act
      await userFileRepository.load();

      // Verify
      verify(mockUserFileDb.insert(expectedFiles));
      verify(mockFileStorage.storeFile(
          utf8.encode(FakeUserFile.ONE_PIXEL_PNG), fileId));
    });

    test('Successful sync saves user file with new revision', () async {
      // Arrange
      final userFileId = 'ididi';
      final lastRevision = 999;
      final userFile = FakeUserFile.createNew(id: userFileId);
      final dirtyFiles = [
        userFile.wrapWithDbModel(dirty: 1, revision: 0),
      ];
      when(mockUserFileDb.getAllDirty())
          .thenAnswer((_) => Future.value(dirtyFiles));
      when(mockUserFileDb.getLastRevision())
          .thenAnswer((_) => Future.value(lastRevision));

      File file = MemoryFileSystem().file('hej.txt');
      await file.writeAsString('hej');
      when(mockFileStorage.getFile(userFileId)).thenAnswer((_) => file);
      final MultipartRequest mockMultipartRequest = MockMultipartRequest();
      final streamedResponse =
          StreamedResponse(ByteStream.fromBytes(await file.readAsBytes()), 200);
      when(mockMultipartRequest.send())
          .thenAnswer((_) => Future.value(streamedResponse));
      when(mockMultiRequestBuilder.generateFileMultipartRequest(
              uri: anyNamed("uri"),
              bytes: anyNamed("bytes"),
              authToken: anyNamed("authToken"),
              sha1: anyNamed("sha1")))
          .thenReturn(mockMultipartRequest);

      final newRevision = 10000;
      final postUserFilesResponse = '''
        [
          {
            "id": "$userFileId",
            "oldRevision": 0,
            "newRevision": $newRevision
          }
        ]
      ''';
      when(
        mockClient.post(
          '$baseUrl/api/v1/data/$userId/storage/items/$lastRevision',
          headers: jsonAuthHeader(Fakes.token),
          body: jsonEncode(dirtyFiles.toList()),
        ),
      ).thenAnswer(
        (_) => Future.value(
          Response(
            postUserFilesResponse,
            200,
          ),
        ),
      );

      when(mockUserFileDb.getById(userFileId)).thenAnswer(
        (_) => Future.value(
          userFile.wrapWithDbModel(dirty: 1, revision: 0),
        ),
      );

      // Act
      await userFileRepository.synchronize();

      // Verify
      verify(mockUserFileDb.insert([
        userFile.wrapWithDbModel(dirty: 0, revision: newRevision),
      ]));
    });
  });
}