part of 'user_file_bloc.dart';

abstract class UserFileEvent extends Equatable {
  const UserFileEvent();
  @override
  List<Object> get props => [];
}

class LoadUserFiles extends UserFileEvent {}

class ImageAdded extends UserFileEvent {
  final String id;
  final String path;
  final File file;

  ImageAdded(this.id, this.path, this.file);

  @override
  List<Object> get props => [id, file];
}
