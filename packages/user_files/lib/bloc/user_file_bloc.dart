import 'dart:async';
import 'dart:io';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:user_files/user_files.dart';

part 'user_file_event.dart';
part 'user_file_state.dart';

class UserFileBloc extends Bloc<UserFileEvent, UserFileState> {
  final UserFileRepository userFileRepository;
  final SyncBloc syncBloc;
  final FileStorage fileStorage;
  late final StreamSubscription _syncSubscription;

  UserFileBloc({
    required this.userFileRepository,
    required this.syncBloc,
    required this.fileStorage,
  }) : super(const UserFilesNotLoaded()) {
    _syncSubscription = syncBloc.stream.listen((_) => add(LoadUserFiles()));
    on<FileAdded>(_fileAdded, transformer: sequential());
    on<LoadUserFiles>(_loadUserFiles, transformer: droppable());
  }

  Future _loadUserFiles(_, Emitter emit) async {
    await userFileRepository.fetchIntoDatabaseSynchronized();
    final storedFiles = await userFileRepository.getAllLoadedFiles();
    if (isClosed) return;
    if (storedFiles.isNotEmpty || await userFileRepository.allDownloaded()) {
      if (isClosed) return;
      emit(UserFilesLoaded(storedFiles, state._tempFiles));
    }
    await _downloadUserFiles(emit);
  }

  Future _downloadUserFiles(Emitter emit) async {
    final downloadedUserFiles =
        await userFileRepository.downloadUserFiles(limit: 10);
    if (isClosed) return;
    if (downloadedUserFiles.isNotEmpty) {
      emit(
        UserFilesLoaded(
          [...state.userFiles, ...downloadedUserFiles],
          state._tempFiles,
        ),
      );
      await _downloadUserFiles(emit);
    }
  }

  Future _fileAdded(
    FileAdded event,
    Emitter emit,
  ) async {
    final unstoredFile = event.unstoredFile;
    emit(
      state.addTempFile(
        unstoredFile.id,
        unstoredFile.file,
      ),
    );

    final fileBytes = event.isImage
        ? await _adjustImageAndStoreThumb(unstoredFile)
        : await unstoredFile.file.readAsBytes();

    await fileStorage.storeFile(fileBytes, unstoredFile.id);
    final userFile = _generateUserFile(
      unstoredFile.id,
      unstoredFile.file.path,
      fileBytes,
    );

    await userFileRepository.save([userFile]);
    syncBloc.add(const SyncFiles());
    if (isClosed) return;
    emit(state.add(userFile));
  }

  Future<List<int>> _adjustImageAndStoreThumb(
      UnstoredAbiliaFile unstoredAbiliaFile) async {
    final originalBytes = await unstoredAbiliaFile.file.readAsBytes();
    final imageResult = await compute<Uint8List, ImageResponse>(
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

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();
    return super.close();
  }
}
