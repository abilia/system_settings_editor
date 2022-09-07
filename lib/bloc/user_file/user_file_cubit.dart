import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:mime/mime.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

part 'user_file_state.dart';

class UserFileCubit extends Cubit<UserFileState> {
  final UserFileRepository userFileRepository;
  final SyncBloc syncBloc;
  final FileStorage fileStorage;
  late final StreamSubscription _syncSubscription;

  UserFileCubit({
    required this.userFileRepository,
    required this.syncBloc,
    required this.fileStorage,
  }) : super(const UserFilesNotLoaded()) {
    _syncSubscription = syncBloc.stream.listen(loadUserFiles);
  }

  Future loadUserFiles([_]) async {
    await userFileRepository.fetchIntoDatabaseSynchronized();
    final storedFiles = await userFileRepository.getAllLoadedFiles();
    if (isClosed) return;
    emit(UserFilesLoaded(storedFiles, state._tempFiles));
    _downloadUserFiles();
  }

  Future _downloadUserFiles() async {
    final downloadedUserFiles =
        await userFileRepository.downloadUserFiles(limit: 10);
    if (downloadedUserFiles.isNotEmpty && !isClosed) {
      emit(
        UserFilesLoaded(
          [...state.userFiles, ...downloadedUserFiles],
          state._tempFiles,
        ),
      );
      _downloadUserFiles();
    }
  }

  Future fileAdded(
    UnstoredAbiliaFile unstoredFile, {
    bool image = false,
  }) async {
    emit(
      state.addTempFile(
        unstoredFile.id,
        unstoredFile.file,
      ),
    );

    final fileBytes = image
        ? await _adjustImageAndStoreThumb(unstoredFile)
        : await unstoredFile.file.readAsBytes();

    await fileStorage.storeFile(fileBytes, unstoredFile.id);
    final userFile = _generateUserFile(
      unstoredFile.id,
      unstoredFile.file.path,
      fileBytes,
    );

    await userFileRepository.save([userFile]);
    syncBloc.add(const FileSaved());
    emit(state.add(userFile));
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

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();
    return super.close();
  }
}
