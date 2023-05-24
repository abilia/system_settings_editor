part of 'user_file_bloc.dart';

class UserFileEvent {}

class FileAdded extends UserFileEvent {
  final UnstoredAbiliaFile unstoredFile;
  final bool isImage;

  FileAdded(this.unstoredFile, {this.isImage = false});
}

class LoadUserFiles extends UserFileEvent {}
