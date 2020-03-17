import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../../mocks.dart';

void main() {
  group('User file bloc', () {
    UserFileBloc userFileBloc;
    UserFileRepository mockUserFileRepository;

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
      userFileBloc = UserFileBloc(
        userFileRepository: mockUserFileRepository,
        pushBloc: MockPushBloc(),
        fileStorage: MockFileStorage(),
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
      File file = MemoryFileSystem().file('test.dart');
      await file.writeAsBytes(fileContent);

      // Act
      userFileBloc.add(FileAdded(fileId, file));

      final expectedFile = UserFile(
        id: fileId,
        sha1: '0f9ba331e2922f27ad7d8d90c4f8198b1eac9f89',
        md5: 'ef593e1899bd8f423f7e747439aa1d46',
        path: 'seagull/$fileId',
        contentType: 'image/png',
        fileSize: 70,
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
      final fileContent = base64.decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==');
      File file = MemoryFileSystem().file('test.dart');
      await file.writeAsBytes(fileContent);

      final fileId2 = 'fileId1';
      File file2 = MemoryFileSystem().file('test.dart');
      await file2.writeAsString('hej');

      // Act
      userFileBloc.add(FileAdded(fileId, file));
      userFileBloc.add(FileAdded(fileId2, file2));

      // Assert
      final expectedFile1 = UserFile(
        id: fileId,
        sha1: '0f9ba331e2922f27ad7d8d90c4f8198b1eac9f89',
        md5: 'ef593e1899bd8f423f7e747439aa1d46',
        path: 'seagull/$fileId',
        contentType: 'image/png',
        fileSize: 70,
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
