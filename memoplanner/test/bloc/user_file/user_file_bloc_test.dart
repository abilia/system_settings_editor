import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late UserFileBloc userFileBloc;
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
    userFileBloc = UserFileBloc(
      userFileRepository: mockUserFileRepository,
      fileStorage: mockedFileStorage,
      syncBloc: FakeSyncBloc(),
    );
  });

  test('Initial state is UserFilesNotLoaded', () {
    expect(userFileBloc.state, const UserFilesNotLoaded());
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
      emits(const UserFilesLoaded([userFile])),
    );
  });

  test('SGC-2342 LoadUserFiles only runs once (droppable)', () async {
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

    when(() => mockUserFileRepository.allDownloaded())
        .thenAnswer((_) => Future.value(false));

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
        userFileBloc.stream,
        emitsInOrder([
          const UserFilesLoaded([userFile]),
          const UserFilesLoaded([userFile, userFile2]),
        ]));

    // Act -- Load files
    userFileBloc
      ..add(LoadUserFiles())
      ..add(LoadUserFiles())
      ..add(LoadUserFiles())
      ..add(LoadUserFiles())
      ..add(LoadUserFiles());

    // Assert --that added file is prioritized
    await expectedStream;

    expect(dlCall, 3);
    verify(() => mockUserFileRepository.downloadUserFiles(
        limit: any(named: 'limit'))).called(3);
  });

  test(
      'SGC-583 LoadUserFiles repeatedly calls download and store until no more files do download, but does not starve an image add call event',
      () async {
    // Arrange
    final file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    final processedFiles = await adjustRotationAndCreateThumbs(fileContent);
    final processedFile1 = processedFiles.originalImage;

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
    when(() => mockUserFileRepository.allDownloaded())
        .thenAnswer((_) => Future.value(false));
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
        userFileBloc.stream,
        emitsInOrder([
          UserFilesNotLoaded({fileId: file}),
          UserFilesLoaded(const [userFile], {fileId: file}),
          UserFilesLoaded(const [userFile, userFile2], {fileId: file}),
          UserFilesLoaded([userFile, userFile2, addedFile]),
        ]));

    // Act -- Loadfiles
    userFileBloc
      ..add(LoadUserFiles())
      // Act -- while downloading files, user adds file
      ..add(FileAdded(
        UnstoredAbiliaFile.forTest(fileId, filePath, file),
        isImage: true,
      ));

    // Assert --that added file is prioritized
    await expectedStream;
  });

  test(
      'State contains UserFilesLoaded with correct user file when file is added',
      () async {
    // Arrange
    final file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    final processedFiles = await adjustRotationAndCreateThumbs(fileContent);
    final processedFile1 = processedFiles.originalImage;

    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));
    when(() => mockUserFileRepository.allDownloaded())
        .thenAnswer((_) => Future.value(true));

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
      userFileBloc.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesLoaded(const [], {fileId: file}),
        UserFilesLoaded([expectedFile]),
      ]),
    );

    // Act
    userFileBloc
      ..add(LoadUserFiles())
      ..add(FileAdded(
        UnstoredAbiliaFile.forTest(fileId, filePath, file),
        isImage: true,
      ));

    // Assert
    await expectedStream;
  });

  test('State contains temp files when UserFileNotLoaded when file is added',
      () async {
    // Arrange
    final file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);

    final expectedStream = expectLater(
      userFileBloc.stream,
      emits(UserFilesNotLoaded({fileId: file})),
    );

    // Act
    userFileBloc.add(FileAdded(
      UnstoredAbiliaFile.forTest(fileId, filePath, file),
      isImage: true,
    ));

    // Assert
    await expectedStream;
  });

  test('State contains two files when two is added in loaded state', () async {
    // Arrange
    const filePath1 = 'test';
    final file = MemoryFileSystem().file(filePath1);
    await file.writeAsBytes(fileContent);
    final processedFiles = await adjustRotationAndCreateThumbs(fileContent);
    final processedFile1 = processedFiles.originalImage;

    const fileId2 = 'fileId1';
    const filePath2 = 'test.dart';
    final file2 = MemoryFileSystem().file(filePath2);
    await file2.writeAsBytes(fileContent);

    when(() => mockUserFileRepository.getAllLoadedFiles())
        .thenAnswer((_) => Future.value([]));
    when(() => mockUserFileRepository.allDownloaded())
        .thenAnswer((_) => Future.value(true));

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
      userFileBloc.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesLoaded(const [], {fileId: file}),
        UserFilesLoaded([expectedFile1]),
        UserFilesLoaded([expectedFile1], {fileId2: file2}),
        UserFilesLoaded([expectedFile1, expectedFile2]),
      ]),
    );

    // Act
    userFileBloc
      ..add(LoadUserFiles())
      ..add(FileAdded(
        UnstoredAbiliaFile.forTest(fileId, filePath1, file),
        isImage: true,
      ))
      ..add(FileAdded(
        UnstoredAbiliaFile.forTest(fileId2, filePath2, file2),
        isImage: true,
      ));

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
      userFileBloc.stream,
      emitsInOrder([
        UserFilesNotLoaded({fileId: file}),
        UserFilesNotLoaded({fileId: file, fileId2: file2}),
      ]),
    );

    // Act
    userFileBloc
      ..add(FileAdded(
        UnstoredAbiliaFile.forTest(fileId, filePath1, file),
        isImage: true,
      ))
      ..add(FileAdded(
        UnstoredAbiliaFile.forTest(fileId2, filePath2, file2),
        isImage: true,
      ));

    // Assert
    await expectStream;
  });
}
