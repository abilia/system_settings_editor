import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/fake_user_files.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/fakes_blocs.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late UserFileBloc userFileBloc;
  late MockUserFileRepository mockUserFileRepository;

  final userFile = UserFile(
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
    userFileBloc = UserFileBloc(
      userFileRepository: mockUserFileRepository,
      pushBloc: FakePushBloc(),
      fileStorage: mockedFileStorage,
      syncBloc: FakeSyncBloc(),
    );
  });

  test('Initial state is UserFilesNotLoaded', () {
    expect(userFileBloc.state, UserFilesNotLoaded());
  });

  test('User files loaded after successful loading of user files', () async {
    // Arrange
    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([userFile]));

    // Act
    userFileBloc.add(LoadUserFiles());

    // Assert
    await expectLater(
      userFileBloc.stream,
      emits(UserFilesLoaded([userFile])),
    );
  });

  test(
      'SGC-583 LoadUserFiles repeatedly calls download and store untill no more files do download, but does not starve an image add call event',
      () async {
    // Arrange
    File file = MemoryFileSystem().file(filePath);
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

    final userFile2 = UserFile(
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

    // Act -- Loadfiles
    userFileBloc.add(LoadUserFiles());
    // Act -- while downloading files, user adds file
    await untilCalled(() =>
        mockUserFileRepository.downloadUserFiles(limit: any(named: 'limit')));
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId, filePath, file)),
    );

    // Assert --that added file is prioritized
    await expectLater(
        userFileBloc.stream,
        emitsInOrder([
          UserFilesLoaded([userFile]),
          UserFilesLoaded([userFile], {fileId: file}),
          UserFilesLoaded([userFile, addedFile]),
          UserFilesLoaded([userFile, addedFile, userFile2]),
        ]));
  });

  test(
      'State contains UserFilesLoaded with correct user file when file is added',
      () async {
    // Arrange
    File file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));

    // Act
    userFileBloc.add(LoadUserFiles());
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId, filePath, file)),
    );

    final expectedFile = UserFile(
      id: fileId,
      sha1: sha1.convert(processedFile1).toString(),
      md5: md5.convert(processedFile1).toString(),
      path: 'seagull/$fileId',
      contentType: 'image/jpeg', // File is converted to jpeg
      fileSize: processedFile1.length,
      deleted: false,
      fileLoaded: true,
    );

    // Assert
    await expectLater(
      userFileBloc.stream,
      emitsInOrder([
        UserFilesLoaded(const [], const {}),
        UserFilesLoaded(const [], {fileId: file}),
        UserFilesLoaded([expectedFile]),
      ]),
    );
  });

  test('State contains temp files when UserFileNotLoaded when file is added',
      () async {
    // Arrange
    File file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);

    // Act
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId, filePath, file)),
    );

    // Assert
    await expectLater(
      userFileBloc.stream,
      emits(UserFilesNotLoaded({fileId: file})),
    );
  });

  test('State contains two files when two is added in loaded state', () async {
    // Arrange
    const filePath1 = 'test';
    File file = MemoryFileSystem().file(filePath1);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    const fileId2 = 'fileId1';
    const filePath2 = 'test.dart';
    File file2 = MemoryFileSystem().file(filePath2);
    await file2.writeAsBytes(fileContent);

    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));

    // Act
    userFileBloc.add(LoadUserFiles());
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId, filePath1, file)),
    );
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId2, filePath2, file2)),
    );

    // Assert
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

    await expectLater(
      userFileBloc.stream,
      emitsInOrder([
        UserFilesLoaded(const [], const {}),
        UserFilesLoaded(const [], {fileId: file}),
        UserFilesLoaded([expectedFile1]),
        UserFilesLoaded([expectedFile1], {fileId2: file2}),
        UserFilesLoaded([expectedFile1, expectedFile2]),
      ]),
    );
  });

  test('State contains two temp files when not loaded state', () async {
    // Arrange
    const filePath1 = 'test';
    File file = MemoryFileSystem().file(filePath1);
    await file.writeAsBytes(fileContent);

    const fileId2 = 'fileId1';
    const filePath2 = 'test.dart';
    File file2 = MemoryFileSystem().file(filePath2);
    await file2.writeAsBytes(fileContent);

    // Act
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId, filePath1, file)),
    );
    userFileBloc.add(
      ImageAdded(UnstoredAbiliaFile.forTest(fileId2, filePath2, file2)),
    );

    // Assert
    await expectLater(
      userFileBloc.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesNotLoaded({fileId: file, fileId2: file2}),
      ]),
    );
  });
}
