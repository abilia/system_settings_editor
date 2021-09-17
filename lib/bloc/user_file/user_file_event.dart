part of 'user_file_bloc.dart';

abstract class UserFileEvent extends Equatable {
  const UserFileEvent();
  @override
  List<Object> get props => [];
}

class LoadUserFiles extends UserFileEvent {}

class _DownloadUserFiles extends UserFileEvent {}

class FileAdded extends UserFileEvent {
  final UnstoredAbiliaFile unstoredFile;

  const FileAdded(this.unstoredFile);

  @override
  List<Object> get props => [unstoredFile];
}

class ImageAdded extends FileAdded {
  const ImageAdded(UnstoredAbiliaFile selectedImage) : super(selectedImage);
}
