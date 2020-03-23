part of 'user_file_bloc.dart';

abstract class UserFileEvent extends Equatable {
  const UserFileEvent();
  @override
  List<Object> get props => [];
}

class LoadUserFiles extends UserFileEvent {}

class FileAdded extends UserFileEvent {
  final String id;
  final List<int> fileBytes;
  final String path;

  FileAdded(this.id, this.fileBytes, this.path);

  @override
  List<Object> get props => [id, fileBytes];
}
