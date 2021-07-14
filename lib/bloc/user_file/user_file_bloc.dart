import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:mime/mime.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

part 'user_file_event.dart';
part 'user_file_state.dart';

class UserFileBloc extends Bloc<UserFileEvent, UserFileState> {
  final UserFileRepository userFileRepository;
  final SyncBloc syncBloc;
  final FileStorage fileStorage;
  late final StreamSubscription pushSubscription;

  UserFileBloc({
    required this.userFileRepository,
    required this.syncBloc,
    required this.fileStorage,
    required PushBloc pushBloc,
  }) : super(UserFilesNotLoaded()) {
    pushSubscription = pushBloc.stream.listen((state) {
      if (state is PushReceived) {
        add(LoadUserFiles());
      }
    });
  }

  @override
  Stream<UserFileState> mapEventToState(
    UserFileEvent event,
  ) async* {
    if (event is ImageAdded) {
      yield state.addTempFile(
        event.selectedImage.id,
        event.selectedImage.file,
      );
      yield* _mapImageAddedToState(event);
    }
    if (event is LoadUserFiles) {
      yield* _mapLoadUserFilesToState();
    }
    if (event is _DownloadUserFiles) {
      yield* _mapDownloadUserFilesToState();
    }
  }

  Stream<UserFileState> _mapLoadUserFilesToState() async* {
    await userFileRepository.fetchIntoDatabaseSynchronized();
    final storedFiles = await userFileRepository.getAllLoadedFiles();
    yield UserFilesLoaded(storedFiles, state._tempFiles);
    add(_DownloadUserFiles());
  }

  Stream<UserFileState> _mapDownloadUserFilesToState() async* {
    final downloadedUserFiles =
        await userFileRepository.downloadUserFiles(limit: 10);
    if (downloadedUserFiles.isNotEmpty) {
      yield UserFilesLoaded(
          [...state.userFiles, ...downloadedUserFiles], state._tempFiles);
      add(_DownloadUserFiles());
    }
  }

  Stream<UserFileState> _mapImageAddedToState(
    ImageAdded event,
  ) async* {
    final originalBytes = await event.selectedImage.file.readAsBytes();
    final userFile = await handleImage(
      originalBytes,
      event.selectedImage.id,
      event.selectedImage.file.path,
    );
    syncBloc.add(FileSaved());
    yield state.add(userFile);
  }

  UserFile generateUserFile(
    String id,
    String path,
    List<int> fileBytes,
  ) {
    final userFile = UserFile(
      id: id,
      sha1: sha1.convert(fileBytes).toString(),
      md5: md5.convert(fileBytes).toString(),
      path: '${FileStorage.folder}/$id',
      contentType: lookupMimeType(path, headerBytes: fileBytes),
      fileSize: fileBytes.length,
      deleted: false,
      fileLoaded: true,
    );
    return userFile;
  }

  Future<UserFile> handleImage(
      List<int> originalBytes, String id, String path) async {
    final imageResult = await compute<List<int>, ImageResponse>(
        adjustRotationAndCreateThumbs, originalBytes);

    await fileStorage.storeFile(imageResult.originalImage, id);
    await fileStorage.storeImageThumb(imageResult.thumb, ImageThumb(id: id));

    final userFile = generateUserFile(id, path, imageResult.originalImage);
    await userFileRepository.save([userFile]);
    return userFile;
  }
}
