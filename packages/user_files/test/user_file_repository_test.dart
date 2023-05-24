import 'dart:convert';
import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';

import 'package:seagull_fakes/all.dart';
import 'package:user_files/user_files.dart';
import 'package:utils/utils.dart';

void main() {
  final mockUserFileDb = MockUserFileDb();
  final mockBaseUrlDb = MockBaseUrlDb();
  const baseUrl = 'http://url.com';
  final mockFileStorage = MockFileStorage();
  final mockClient = MockBaseClient();
  final mockMultiRequestBuilder = MockMultipartRequestBuilder();
  const userId = 1;
  final userFileRepository = UserFileRepository(
    baseUrlDb: mockBaseUrlDb,
    fileStorage: mockFileStorage,
    client: mockClient,
    userFileDb: mockUserFileDb,
    loginDb: MockLoginDb(),
    userId: userId,
    multipartRequestBuilder: mockMultiRequestBuilder,
  );

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(Uint8List(1));
    registerFallbackValue(const ImageThumb(id: ''));
  });

  setUp(() async {
    when(() => mockBaseUrlDb.baseUrl).thenReturn(baseUrl);
    when(() => mockUserFileDb.insert(any())).thenAnswer((invocation) async {});
  });

  tearDown(() {
    reset(mockUserFileDb);
    reset(mockClient);
    reset(mockFileStorage);
  });

  test('Save saves to db', () async {
    when(() => mockUserFileDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    final userFile1 = FakeUserFile.createNew(id: 'fakeId1');
    await userFileRepository.save([userFile1]);
    verify(() => mockUserFileDb.insertAndAddDirty([userFile1]));
  });

  test('Load saves to db and stores to file storage', () async {
    // Arrange
    when(() => mockUserFileDb.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));
    const revision = 99;
    when(() => mockUserFileDb.getLastRevision())
        .thenAnswer((_) => Future.value(revision));

    const fileId = 'id';
    const userFilesJson = '''
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
      () => mockClient.get(
          '$baseUrl/api/v1/data/$userId/storage/items?revision=$revision'
              .toUri()),
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

    when(() => mockUserFileDb.getMissingFiles(limit: any(named: 'limit')))
        .thenAnswer((_) => Future.value(expectedFiles.map((f) => f.model)));

    when(
      () => mockClient.get(fileIdUrl(baseUrl, userId, fileId).toUri()),
    ).thenAnswer(
      (_) => Future.value(
        Response(
          FakeUserFile.onePixelPng,
          200,
        ),
      ),
    );

    // Act
    await userFileRepository.fetchIntoDatabaseSynchronized();
    await userFileRepository.downloadUserFiles();

    // Verify
    verify(() => mockUserFileDb.insert(expectedFiles));
    verify(() => mockFileStorage.storeFile(
        utf8.encode(FakeUserFile.onePixelPng), fileId));
  });

  test('Successful sync saves user file with new revision', () async {
    // Arrange
    const userFileId = 'ididi';
    const lastRevision = 999;
    final userFile = FakeUserFile.createNew(id: userFileId);
    final dirtyFiles = [
      userFile.wrapWithDbModel(dirty: 1, revision: 0),
    ];
    when(() => mockUserFileDb.getAllDirty())
        .thenAnswer((_) => Future.value(dirtyFiles));
    when(() => mockUserFileDb.getLastRevision())
        .thenAnswer((_) => Future.value(lastRevision));

    final file = MemoryFileSystem().file('hej.txt');
    await file.writeAsString('hej');
    when(() => mockFileStorage.getFile(userFileId)).thenAnswer((_) => file);
    final MultipartRequest mockMultipartRequest = MockMultipartRequest();
    final streamedResponse =
        StreamedResponse(ByteStream.fromBytes(await file.readAsBytes()), 200);
    when(() => mockMultipartRequest.send())
        .thenAnswer((_) => Future.value(streamedResponse));
    when(() => mockMultiRequestBuilder.generateFileMultipartRequest(
        uri: any(named: 'uri'),
        bytes: any(named: 'bytes'),
        authToken: any(named: 'authToken'),
        sha1: any(named: 'sha1'))).thenReturn(mockMultipartRequest);

    const newRevision = 10000;
    const postUserFilesResponse = '''
        [
          {
            "id": "$userFileId",
            "oldRevision": 0,
            "newRevision": $newRevision
          }
        ]
      ''';
    when(
      () => mockClient.post(
        '$baseUrl/api/v1/data/$userId/storage/items/$lastRevision'.toUri(),
        headers: jsonHeader,
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

    when(() => mockUserFileDb.getById(userFileId)).thenAnswer(
      (_) => Future.value(
        userFile.wrapWithDbModel(dirty: 1, revision: 0),
      ),
    );

    // Act
    await userFileRepository.synchronize();

    // Verify
    verify(() => mockUserFileDb.insert([
          userFile.wrapWithDbModel(dirty: 0, revision: newRevision),
        ]));
  });

  test('synchronize - calls fetch before posting', () async {
    // Arrange
    when(() => mockUserFileDb.getLastRevision())
        .thenAnswer((_) => Future.value(1));
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) => Future.value(Response('[]', 200)));
    when(() => mockUserFileDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));

    // Act
    await userFileRepository.synchronize();

    // Verify
    verifyInOrder([
      () => mockUserFileDb.getLastRevision(),
      () => mockClient.get(any(), headers: any(named: 'headers')),
      () => mockUserFileDb.insert([]),
      () => mockUserFileDb.getAllDirty(),
    ]);
  });

  test('Missing continues download but does not return userFile', () async {
    final failsOnId = {1, 5};
    List<UserFile> userFiles(int limit) => List.generate(
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
      () => mockUserFileDb.getMissingFiles(limit: any(named: 'limit')),
    ).thenAnswer(
      (invocation) =>
          Future.value(userFiles(invocation.namedArguments.values.first)),
    );

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((r) {
      final Uri uri = r.positionalArguments[0];
      final url = uri.path;
      final p = int.tryParse(url.split('?').first.split('/').last);
      if (failsOnId.contains(p)) {
        return Future.value(Response('not found', 400));
      }
      return Future.value(Response(FakeUserFile.onePixelPng, 200));
    });
    when(() => mockFileStorage.storeFile(any(), any()))
        .thenAnswer((_) => Future.value());
    when(() => mockFileStorage.storeImageThumb(any(), any()))
        .thenAnswer((_) => Future.value());
    when(() => mockUserFileDb.setFileLoadedForId(any()))
        .thenAnswer((_) => Future.value());

    const lim = 12;
    final expectedToSuccessed =
        {for (var i = 0; i < lim; i++) i}.difference(failsOnId);
    final expectedSuccesses = expectedToSuccessed.length;

    // Act
    final res = await userFileRepository.downloadUserFiles(limit: lim);

    // Assert -- Set loaded, stores and returns all succeded

    verify(() => mockUserFileDb.setFileLoadedForId(any()))
        .called(expectedSuccesses);
    verify(() => mockFileStorage.storeFile(any(), any()))
        .called(expectedSuccesses);
    expect(res.length, expectedSuccesses);
  });
}
