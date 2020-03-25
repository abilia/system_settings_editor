import 'dart:async';
import 'dart:io';

import 'package:image/image.dart' as img;
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
    if (event is FileAdded) {
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
    FileAdded event,
  ) async* {
    final originalBytes = await event.file.readAsBytes();
    final originalContentType =
        lookupMimeType(event.file.path, headerBytes: originalBytes);
    final fileBytes = originalContentType.startsWith('image')
        ? processImageBytes(originalBytes)
        : originalBytes;
    final userFile = UserFile(
      id: event.id,
      sha1: sha1.convert(fileBytes).toString(),
      md5: md5.convert(fileBytes).toString(),
      path: 'seagull/${event.id}',
      contentType: lookupMimeType(event.file.path, headerBytes: fileBytes),
      fileSize: fileBytes.length,
      deleted: false,
    );
    await Future.wait([
      userFileRepository.save([userFile]),
      fileStorage.storeFile(fileBytes, event.id),
    ]);
    syncBloc.add(FileSaved());
    final currentState = state;
    if (currentState is UserFilesLoaded) {
      yield UserFilesLoaded(currentState.userFiles.followedBy([userFile]));
    } else {
      yield UserFilesLoaded([userFile]);
    }
    // TODO Save new sortable to the uploads folder
  }

  List<int> processImageBytes(List<int> originalBytes) {
    final bakedOrientationImage =
        img.bakeOrientation(img.decodeImage(originalBytes));
    return img.encodeJpg(bakedOrientationImage, quality: 20);
  }
}
