part of 'user_file_bloc.dart';

abstract class UserFileEvent extends Equatable {
  const UserFileEvent();
  @override
  List<Object> get props => [];
}

class LoadUserFiles extends UserFileEvent {}

class _DownloadUserFiles extends UserFileEvent {}

class ImageAdded extends UserFileEvent {
  final SelectedImage selectedImage;
  String get id => selectedImage.id;
  String get path => selectedImage.path;
  File get file => selectedImage.file;

  const ImageAdded(this.selectedImage);

  @override
  List<Object> get props => [id, file];
}
