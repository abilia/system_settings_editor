import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';

part 'user_file_event.dart';
part 'user_file_state.dart';

class UserFileBloc extends Bloc<UserFileEvent, UserFileState> {
  final UserFileRepository userFileRepository;
  final SyncBloc syncBloc;
  final FileStorage fileStorage;

  UserFileBloc({
    @required this.userFileRepository,
    @required this.syncBloc,
    @required this.fileStorage,
  });

  @override
  UserFileState get initialState => UserFilesNotLoaded();

  @override
  Stream<UserFileState> mapEventToState(
    UserFileEvent event,
  ) async* {
    if (event is FileAdded) {
      print('File added in user file bloc');
      yield* _mapFileAddedToState(event);
    }
    if (event is LoadUserFiles) {
      print('Load user files');
      yield* _mapLoadUserFilesToState();
    }
  }

  Stream<UserFileState> _mapLoadUserFilesToState() async* {
    final userFiles = await userFileRepository.load();
    print('got user files $userFiles');
    yield UserFilesLoaded(userFiles);
  }

  Stream<UserFileState> _mapFileAddedToState(
    FileAdded event,
  ) async* {
    final fileBytes = event.file.readAsBytesSync();
    final sha1Hex = sha1.convert(fileBytes).toString();
    final md5Hex = md5.convert(fileBytes).toString();
    final path = 'seagull/${event.id}';
    final contentType = lookupMimeType(event.file.path, headerBytes: fileBytes);
    final fileSize = await event.file.length();
    final userFile = UserFile(
      id: event.id,
      sha1: sha1Hex,
      md5: md5Hex,
      path: path,
      contentType: contentType,
      fileSize: fileSize,
      deleted: false,
    );
    await userFileRepository.save([userFile]);
    await fileStorage.storeFile(fileBytes, event.id);
    syncBloc.add(FileSaved());
    final currentState = state;
    if (currentState is UserFilesLoaded) {
      yield UserFilesLoaded(currentState.userFiles.followedBy([userFile]));
    } else {
      yield UserFilesLoaded([userFile]);
    }
    // TODO Save new sortable to the uploads folder
  }
}
