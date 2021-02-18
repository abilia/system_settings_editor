import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/fake_user_files.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  UserFileBloc userFileBloc;
  UserFileRepository mockUserFileRepository;
  MockFileStorage mockedFileStorage;

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

  final fileId = 'file1';
  final fileContent = base64.decode(FakeUserFile.ONE_PIXEL_PNG);
  final filePath = 'test.dart';

  setUp(() {
    mockUserFileRepository = MockUserFileRepository();
    mockedFileStorage = MockFileStorage();
    when(mockUserFileRepository.save(any)).thenAnswer((_) => Future.value());
    when(mockUserFileRepository.allFilesLoaded())
        .thenAnswer((_) => Future.value(true));
    when(mockedFileStorage.storeFile(any, any))
        .thenAnswer((_) => Future.value());
    userFileBloc = UserFileBloc(
      userFileRepository: mockUserFileRepository,
      pushBloc: MockPushBloc(),
      fileStorage: mockedFileStorage,
      syncBloc: MockSyncBloc(),
    );
  });

  test('Initial state is UserFilesNotLoaded', () {
    expect(userFileBloc.state, UserFilesNotLoaded());
  });

  test('User files loaded after successful loading of user files', () async {
    // Arrange
    when(mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([userFile]));

    // Act
    userFileBloc.add(LoadUserFiles());

    // Assert
    await untilCalled(mockUserFileRepository.fetchIntoDatabaseSynchronized());
    await untilCalled(
        mockUserFileRepository.getAndStoreFileData(limit: anyNamed('limit')));
    await expectLater(
      userFileBloc,
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

    when(mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([userFile]));
    when(mockUserFileRepository.allFilesLoaded())
        .thenAnswer((_) => Future.value(false));

    // Act -- Loadfiles
    userFileBloc.add(LoadUserFiles());

    // Assert -- that first calls to repository
    await untilCalled(mockUserFileRepository.fetchIntoDatabaseSynchronized());
    await untilCalled(
        mockUserFileRepository.getAndStoreFileData(limit: anyNamed('limit')));
    expect(
      userFileBloc,
      emits(
        UserFilesLoaded([userFile]),
      ),
    );

    // Act -- try add new image while downloadning
    userFileBloc
        .add(ImageAdded(SelectedImage(id: fileId, path: filePath, file: file)));
    await untilCalled(mockedFileStorage.storeFile(any, any));
    await untilCalled(mockedFileStorage.storeImageThumb(any, any));

    // Assert -- Added file added
    expect(
      userFileBloc,
      emits(UserFilesLoaded([userFile].followedBy([addedFile]))),
    );

    // Arrange -- next time download calls, return no more to download
    when(mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([userFile, addedFile, userFile2]));
    when(mockUserFileRepository.allFilesLoaded())
        .thenAnswer((_) => Future.value(true));

    // Assert -- last file downloaded
    await untilCalled(
        mockUserFileRepository.getAndStoreFileData(limit: anyNamed('limit')));
    await expectLater(
      userFileBloc,
      emitsInOrder([
        UserFilesLoaded([userFile].followedBy([addedFile])),
        UserFilesLoaded([userFile, addedFile, userFile2]),
      ]),
    );
  });

  test(
      'State contains UserFilesLoaded with correct user file when file is added',
      () async {
    // Arrange
    File file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    // Act
    userFileBloc
        .add(ImageAdded(SelectedImage(id: fileId, path: filePath, file: file)));

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
      userFileBloc,
      emits(UserFilesLoaded([expectedFile])),
    );
  });

  test('State contains two files when two is added', () async {
    // Arrange

    final filePath1 = 'test';
    File file = MemoryFileSystem().file(filePath1);
    await file.writeAsBytes(fileContent);
    final processedFile1 = await adjustImageSizeAndRotation(fileContent);

    final fileId2 = 'fileId1';
    final filePath2 = 'test.dart';
    File file2 = MemoryFileSystem().file(filePath2);
    await file2.writeAsBytes(fileContent);

    // Act
    userFileBloc.add(
      ImageAdded(SelectedImage(id: fileId, path: filePath1, file: file)),
    );
    userFileBloc.add(
      ImageAdded(SelectedImage(id: fileId2, path: filePath2, file: file2)),
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
      userFileBloc,
      emitsInOrder([
        UserFilesLoaded([expectedFile1]),
        UserFilesLoaded([expectedFile1].followedBy([expectedFile2])),
      ]),
    );
  });
}
