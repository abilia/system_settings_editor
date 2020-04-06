import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/utils/all.dart';

part 'user_file_event.dart';
part 'user_file_state.dart';

class UserFileBloc extends Bloc<UserFileEvent, UserFileState> {
  final UserFileRepository userFileRepository;
  final SyncBloc syncBloc;
  final FileStorage fileStorage;
  StreamSubscription pushSubscription;

  UserFileBloc({
    @required this.userFileRepository,
    @required this.syncBloc,
    @required this.fileStorage,
    @required PushBloc pushBloc,
  }) {
    pushSubscription = pushBloc.listen((state) {
      if (state is PushReceived) {
        add(LoadUserFiles());
      }
    });
  }

  @override
  UserFileState get initialState => UserFilesNotLoaded();

  @override
  Stream<UserFileState> mapEventToState(
    UserFileEvent event,
  ) async* {
    if (event is ImageAdded) {
      yield* _mapFileAddedToState(event);
    }
    if (event is LoadUserFiles) {
      yield* _mapLoadUserFilesToState();
    }
  }

  Stream<UserFileState> _mapLoadUserFilesToState() async* {
    final userFiles = await userFileRepository.load();
    yield UserFilesLoaded(userFiles);
  }

  Stream<UserFileState> _mapFileAddedToState(
    ImageAdded event,
  ) async* {
    final originalBytes = await event.file.readAsBytes();
    final userFile =
        await handleImage(originalBytes, event.id, event.file.path);
    syncBloc.add(FileSaved());
    final currentState = state;
    if (currentState is UserFilesLoaded) {
      yield UserFilesLoaded(currentState.userFiles.followedBy([userFile]));
    } else {
      yield UserFilesLoaded([userFile]);
    }
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
      path: 'seagull/$id',
      contentType: lookupMimeType(path, headerBytes: fileBytes),
      fileSize: fileBytes.length,
      deleted: false,
    );
    return userFile;
  }

  Future<UserFile> handleImage(
      List<int> originalBytes, String id, String path) async {
    final ImageResult imageResult = await compute<List<int>, ImageResult>(
        imageProcessingIsolate, originalBytes);

    final userFile = generateUserFile(id, path, imageResult.originalImage);

    await userFileRepository.save([userFile]);
    await fileStorage.storeFile(imageResult.originalImage, id);
    await fileStorage.storeImageThumb(
        imageResult.thumbImage, ImageThumb(id: id));
    return userFile;
  }
}
