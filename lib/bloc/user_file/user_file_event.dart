part of 'user_file_bloc.dart';

abstract class UserFileEvent extends Equatable {
  const UserFileEvent();
  @override
  List<Object> get props => [];
}

class LoadUserFiles extends UserFileEvent {}

class FileAdded extends UserFileEvent {
  final String id;
  final File file;

  FileAdded(this.id, this.file);

  @override
  List<Object> get props => [id, file];
}
