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
  }) : super(const UserFilesNotLoaded()) {
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
    if (event is FileAdded) {
      yield* _mapFileAddedToState(event);
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

  Stream<UserFileState> _mapFileAddedToState(FileAdded event) async* {
    yield state.addTempFile(
      event.unstoredFile.id,
      event.unstoredFile.file,
    );

    final fileBytes = event is ImageAdded
        ? await _adjustImageAndStoreThumb(event.unstoredFile)
        : await event.unstoredFile.file.readAsBytes();

    await fileStorage.storeFile(fileBytes, event.unstoredFile.id);
    final userFile = _generateUserFile(
        event.unstoredFile.id, event.unstoredFile.file.path, fileBytes);

    await userFileRepository.save([userFile]);
    syncBloc.add(SyncEvent.fileSaved);
    yield state.add(userFile);
  }

  Future<List<int>> _adjustImageAndStoreThumb(
      UnstoredAbiliaFile unstoredAbiliaFile) async {
    final originalBytes = await unstoredAbiliaFile.file.readAsBytes();
    final imageResult = await compute<List<int>, ImageResponse>(
      adjustRotationAndCreateThumbs,
      originalBytes,
    );
    await fileStorage.storeImageThumb(
      imageResult.thumb,
      ImageThumb(id: unstoredAbiliaFile.id),
    );
    return imageResult.originalImage;
  }

  UserFile _generateUserFile(
    String id,
    String path,
    List<int> fileBytes,
  ) =>
      UserFile(
        id: id,
        sha1: sha1.convert(fileBytes).toString(),
        md5: md5.convert(fileBytes).toString(),
        path: '${FileStorage.folder}/$id',
        contentType: lookupMimeType(path, headerBytes: fileBytes),
        fileSize: fileBytes.length,
        deleted: false,
        fileLoaded: true,
      );
}
