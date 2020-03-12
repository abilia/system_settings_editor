import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'user_file_event.dart';
part 'user_file_state.dart';

class UserFileBloc extends Bloc<UserFileEvent, UserFileState> {
  final UserFileRepository userFileRepository;

  UserFileBloc({
    @required this.userFileRepository,
  });

  @override
  UserFileState get initialState => UserFileInitial();

  @override
  Stream<UserFileState> mapEventToState(
    UserFileEvent event,
  ) async* {
    if (event is FileAdded) {
      // Create UserFile and save to db
      final fileBytes = event.file.readAsBytesSync();
      final sha1Hex = sha1.convert(fileBytes).toString();
      final path = 'seagull/${event.id}';
      final contentType =
          lookupMimeType(event.file.path, headerBytes: fileBytes);
      final fileSize = await event.file.length();
      final userFile = UserFile(
        id: event.id,
        sha1: sha1Hex,
        path: path,
        contentType: contentType,
        fileSize: fileSize,
        deleted: false,
      );
      await userFileRepository.save([userFile]);
      // Save file to file storage
      
      // Save new sortable to the uploads folder
    }
  }
}
