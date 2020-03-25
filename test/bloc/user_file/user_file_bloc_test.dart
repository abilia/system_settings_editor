import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/fake_user_files.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../../mocks.dart';

void main() {
  group('User file bloc', () {
    UserFileBloc userFileBloc;
    UserFileRepository mockUserFileRepository;
    MockFileStorage mockedFileStorage;

    final userFile = UserFile(
      id: "",
      sha1: "",
      md5: "",
      path: "",
      contentType: "",
      fileSize: 1,
      deleted: false,
    );

    setUp(() {
      mockUserFileRepository = MockUserFileRepository();
      mockedFileStorage = MockFileStorage();
      when(mockUserFileRepository.save(any)).thenAnswer((_) => Future.value());
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
      expect(userFileBloc.initialState, UserFilesNotLoaded());
    });

    test('User files loaded after successful loading of user files', () async {
      when(mockUserFileRepository.load())
          .thenAnswer((_) => Future.value([userFile]));
      userFileBloc.add(LoadUserFiles());
      await expectLater(
        userFileBloc,
        emitsInOrder([
          UserFilesNotLoaded(),
          UserFilesLoaded([userFile]),
        ]),
      );
    });

    test(
        'State contains UserFilesLoaded with correct user file when file is added',
        () async {
      // Arrange
      final fileId = 'file1';
      final fileContent = base64.decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==');
      final String filePath = 'test.dart';
      File file = MemoryFileSystem().file(filePath);
      await file.writeAsBytes(fileContent);

      // Act
      userFileBloc.add(FileAdded(fileId, file));

      final expectedFile = UserFile(
        id: fileId,
        sha1: '6584be044e97e76725933e55db4bc8e155b66970',
        md5: 'c9f224037b29bd87f4930a2f6fc12257',
        path: 'seagull/$fileId',
        contentType: 'image/jpeg', // File is converted to jpeg
        fileSize: 614,
        deleted: false,
      );

      // Assert
      await expectLater(
        userFileBloc,
        emitsInOrder([
          UserFilesNotLoaded(),
          UserFilesLoaded([expectedFile]),
        ]),
      );
    });

    test('State contains two files when two is added', () async {
      // Arrange
      final fileId = 'file1';
      final fileContent = base64.decode(FakeUserFile.ONE_PIXEL_PNG);
      final filePath1 = 'test';
      File file = MemoryFileSystem().file(filePath1);
      await file.writeAsBytes(fileContent);

      final fileId2 = 'fileId1';
      final filePath2 = 'test.dart';
      File file2 = MemoryFileSystem().file(filePath2);
      await file2.writeAsString('hej');

      // Act
      userFileBloc.add(FileAdded(fileId, file));
      userFileBloc.add(FileAdded(fileId2, file2));

      // Assert
      final expectedFile1 = UserFile(
        id: fileId,
        sha1: '6584be044e97e76725933e55db4bc8e155b66970',
        md5: 'c9f224037b29bd87f4930a2f6fc12257',
        path: 'seagull/$fileId',
        contentType: 'image/jpeg', // images are converted to jpeg
        fileSize: 614,
        deleted: false,
      );

      final expectedFile2 = UserFile(
        id: fileId2,
        sha1: 'c412b37f8c0484e6db8bce177ae88c5443b26e92',
        md5: '541c57960bb997942655d14e3b9607f9',
        path: 'seagull/$fileId2',
        contentType: 'text/x-dart',
        fileSize: 3,
        deleted: false,
      );

      await expectLater(
        userFileBloc,
        emitsInOrder([
          UserFilesNotLoaded(),
          UserFilesLoaded([expectedFile1]),
          UserFilesLoaded([expectedFile1].followedBy([expectedFile2])),
        ]),
      );
    });
  });
}
