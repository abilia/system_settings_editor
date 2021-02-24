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

import '../../mocks.dart';

void main() {
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
    client: mockClient,
    userFileDb: mockUserFileDb,
    userId: userId,
    multipartRequestBuilder: mockMultiRequestBuilder,
  );

  tearDown(() {
    reset(mockUserFileDb);
    reset(mockClient);
    reset(mockFileStorage);
  });

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

    when(mockUserFileDb.getMissingFiles(limit: anyNamed('limit')))
        .thenAnswer((_) => Future.value(expectedFiles.map((f) => f.model)));

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
            uri: anyNamed('uri'),
            bytes: anyNamed('bytes'),
            authToken: anyNamed('authToken'),
            sha1: anyNamed('sha1')))
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

  test('synchronize - calls fetch before posting', () async {
    // Arrange
    when(mockUserFileDb.getLastRevision()).thenAnswer((_) => Future.value(1));
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) => Future.value(Response('[]', 200)));
    when(mockUserFileDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    // Act
    await userFileRepository.synchronize();

    // Verify
    verifyInOrder([
      mockUserFileDb.getLastRevision(),
      mockClient.get(any, headers: anyNamed('headers')),
      mockUserFileDb.insert([]),
      mockUserFileDb.getAllDirty(),
    ]);
  });

  test('Missing continues download but does not return userFile', () async {
    final failsOnId = {1, 5};
    final userFiles = (int limit) => List.generate(
          limit,
          (index) => UserFile(
            id: '$index',
            contentType: index > (limit ~/ 2) ? 'contentType' : 'image/jpeg',
            sha1: 'sha1',
            md5: 'md5',
            path: 'path/$index',
            fileSize: 1,
            fileLoaded: false,
            deleted: false,
          ),
        );

    // Arrange
    when(
      mockUserFileDb.getMissingFiles(limit: anyNamed('limit')),
    ).thenAnswer(
      (invocation) =>
          Future.value(userFiles(invocation.namedArguments.values.first)),
    );

    when(
      mockClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((r) {
      final String url = r.positionalArguments[0];
      final p = int.tryParse(url.split('?').first.split('/').last);
      if (failsOnId.contains(p)) {
        return Future.value(Response('not found', 400));
      }
      return Future.value(Response(FakeUserFile.ONE_PIXEL_PNG, 200));
    });
    when(mockFileStorage.storeFile(any, any)).thenAnswer((_) => Future.value());
    when(mockFileStorage.storeImageThumb(any, any))
        .thenAnswer((_) => Future.value());
    when(mockUserFileDb.setFileLoadedForId(any))
        .thenAnswer((_) => Future.value());

    final lim = 12;
    final expectedToSuccessed =
        {for (var i = 0; i < lim; i++) i}.difference(failsOnId);
    final expectedSuccesses = expectedToSuccessed.length;

    // Act
    final res = await userFileRepository.downloadUserFiles(limit: lim);

    // Assert -- Set loaded, stores and returns all succeded

    verify(mockUserFileDb.setFileLoadedForId(any)).called(expectedSuccesses);
    verify(mockFileStorage.storeFile(any, any)).called(expectedSuccesses);
    expect(res.length, expectedSuccesses);
  });
}
