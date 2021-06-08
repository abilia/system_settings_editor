// @dart=2.9

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

  const ImageAdded(this.selectedImage);

  @override
  List<Object> get props => [selectedImage];
}
