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
      fileLoaded: true,
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
      final processedFile1 = await adjustImageSizeAndRotation(fileContent);

      // Act
      userFileBloc.add(ImageAdded(fileId, file));

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
      final processedFile1 = await adjustImageSizeAndRotation(fileContent);

      final fileId2 = 'fileId1';
      final filePath2 = 'test.dart';
      File file2 = MemoryFileSystem().file(filePath2);
      await file2.writeAsBytes(fileContent);

      // Act
      userFileBloc.add(ImageAdded(fileId, file));
      userFileBloc.add(ImageAdded(fileId2, file2));

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
          UserFilesNotLoaded(),
          UserFilesLoaded([expectedFile1]),
          UserFilesLoaded([expectedFile1].followedBy([expectedFile2])),
        ]),
      );
    });
  });
}
