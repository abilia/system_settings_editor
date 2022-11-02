import 'dart:convert';

import 'package:file/memory.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late UserFileCubit userFileCubit;
  late MockUserFileRepository mockUserFileRepository;

  const userFile = UserFile(
    id: '',
    sha1: '',
    md5: '',
    path: '',
    contentType: '',
    fileSize: 1,
    deleted: false,
    fileLoaded: true,
  );

  const fileId = 'file1';
  final fileContent = base64.decode(FakeUserFile.onePixelPng);
  const filePath = 'test.dart';

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockUserFileRepository = MockUserFileRepository();
    when(() => mockUserFileRepository.save(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => mockUserFileRepository.downloadUserFiles(
        limit: any(named: 'limit'))).thenAnswer((_) => Future.value([]));
    when(() => mockUserFileRepository.fetchIntoDatabaseSynchronized())
        .thenAnswer((_) async {});
    final mockedFileStorage = MockFileStorage();
    when(() => mockedFileStorage.storeFile(any(), any()))
        .thenAnswer((_) => Future.value());
    when(() => mockedFileStorage.storeImageThumb(any(), any()))
        .thenAnswer((_) => Future.value());
    userFileCubit = UserFileCubit(
      userFileRepository: mockUserFileRepository,
      fileStorage: mockedFileStorage,
      syncBloc: FakeSyncBloc(),
    );
  });

  test('Initial state is UserFilesNotLoaded', () {
    expect(userFileCubit.state, const UserFilesNotLoaded());
  });

  test('User files loaded after successful loading of user files', () async {
    // Arrange
    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([userFile]));

    // Act
    userFileCubit.loadUserFiles();

    // Assert
    await expectLater(
      userFileCubit.stream,
      emits(const UserFilesLoaded([userFile])),
    );
  });

  test(
      'SGC-583 LoadUserFiles repeatedly calls download and store untill no more files do download, but does not starve an image add call event',
      () async {
    // Arrange
    final file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    final addedFile = UserFile(
      id: fileId,
      sha1: sha1.convert(processedFile1).toString(),
      md5: md5.convert(processedFile1).toString(),
      path: 'seagull/$fileId',
      contentType: 'image/jpeg', // File is converted to jpeg
      fileSize: processedFile1.length,
      deleted: false,
      fileLoaded: true,
    );

    const userFile2 = UserFile(
      id: '1',
      sha1: '2',
      md5: '3',
      path: '4',
      contentType: '5',
      fileSize: 1,
      deleted: false,
      fileLoaded: true,
    );

    var dlCall = 0;
    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));
    when(() => mockUserFileRepository.downloadUserFiles(
        limit: any(named: 'limit'))).thenAnswer((_) {
      switch (dlCall++) {
        case 0:
          return Future.value([userFile]);
        case 1:
          return Future.value([userFile2]);
        default:
          return Future.value(<UserFile>[]);
      }
    });

    final expectedStream = expectLater(
        userFileCubit.stream,
        emitsInOrder([
          UserFilesNotLoaded({fileId: file}),
          UserFilesLoaded(const [], {fileId: file}),
          UserFilesLoaded(const [userFile], {fileId: file}),
          UserFilesLoaded(const [userFile, userFile2], {fileId: file}),
          UserFilesLoaded([userFile, userFile2, addedFile]),
        ]));

    // Act -- Loadfiles
    userFileCubit.loadUserFiles();
    // Act -- while downloading files, user adds file
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId, filePath, file),
      image: true,
    );

    // Assert --that added file is prioritized
    await expectedStream;
  });

  test(
      'State contains UserFilesLoaded with correct user file when file is added',
      () async {
    // Arrange
    final file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));

    final expectedFile = UserFile(
      id: fileId,
      sha1: sha1.convert(processedFile1).toString(),
      md5: md5.convert(processedFile1).toString(),
      path: 'seagull/$fileId',
      contentType: 'image/jpeg',
      // File is converted to jpeg
      fileSize: processedFile1.length,
      deleted: false,
      fileLoaded: true,
    );
    final expectedStream = expectLater(
      userFileCubit.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesLoaded(const [], {fileId: file}),
        UserFilesLoaded([expectedFile]),
      ]),
    );

    // Act
    userFileCubit.loadUserFiles();
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId, filePath, file),
      image: true,
    );

    // Assert
    await expectedStream;
  });

  test('State contains temp files when UserFileNotLoaded when file is added',
      () async {
    // Arrange
    final file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);

    final expectedStream = expectLater(
      userFileCubit.stream,
      emits(UserFilesNotLoaded({fileId: file})),
    );

    // Act
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId, filePath, file),
      image: true,
    );

    // Assert
    await expectedStream;
  });

  test('State contains two files when two is added in loaded state', () async {
    // Arrange
    const filePath1 = 'test';
    final file = MemoryFileSystem().file(filePath1);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    const fileId2 = 'fileId1';
    const filePath2 = 'test.dart';
    final file2 = MemoryFileSystem().file(filePath2);
    await file2.writeAsBytes(fileContent);

    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));

    final expectedFile1 = UserFile(
      id: fileId,
      sha1: sha1.convert(processedFile1).toString(),
      md5: md5.convert(processedFile1).toString(),
      path: 'seagull/$fileId',
      contentType: 'image/jpeg', // images are converted to jpeg
      fileSize: processedFile1.length,
      deleted: false,
      fileLoaded: true,
    );

    final expectedFile2 = UserFile(
      id: fileId2,
      sha1: sha1.convert(processedFile1).toString(),
      md5: md5.convert(processedFile1).toString(),
      path: 'seagull/$fileId2',
      contentType: 'image/jpeg',
      fileSize: processedFile1.length,
      deleted: false,
      fileLoaded: true,
    );

    final expectedStream = expectLater(
      userFileCubit.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesNotLoaded({fileId: file, fileId2: file2}),
        UserFilesLoaded(const [], {fileId: file, fileId2: file2}),
        isA<UserFilesLoaded>(),
        _StoredFileMatcher([expectedFile1, expectedFile2]),
      ]),
    );

    // Act
    userFileCubit.loadUserFiles();
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId, filePath1, file),
      image: true,
    );
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId2, filePath2, file2),
      image: true,
    );

    // Assert
    await expectedStream;
  });

  test('State contains two temp files when not loaded state', () async {
    // Arrange
    const filePath1 = 'test';
    final file = MemoryFileSystem().file(filePath1);
    await file.writeAsBytes(fileContent);

    const fileId2 = 'fileId1';
    const filePath2 = 'test.dart';
    final file2 = MemoryFileSystem().file(filePath2);
    await file2.writeAsBytes(fileContent);

    final expectStream = expectLater(
      userFileCubit.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesNotLoaded({fileId: file, fileId2: file2}),
      ]),
    );

    // Act
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId, filePath1, file),
      image: true,
    );
    userFileCubit.fileAdded(
      UnstoredAbiliaFile.forTest(fileId2, filePath2, file2),
      image: true,
    );

    // Assert
    await expectStream;
  });
}

class _StoredFileMatcher extends Matcher {
  final List<UserFile> files;

  _StoredFileMatcher(this.files);

  @override
  Description describe(Description description) =>
      unorderedEquals(files).describe(description);

  @override
  bool matches(item, Map matchState) =>
      (item is UserFilesLoaded) &&
      unorderedEquals(files).matches(item.userFiles, matchState);
}
