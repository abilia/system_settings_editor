part of 'image_archive_bloc.dart';

abstract class ImageArchiveEvent extends Equatable {
  const ImageArchiveEvent();
}

class FolderChanged extends ImageArchiveEvent {
  final String folderId;

  FolderChanged(this.folderId);

  @override
  List<Object> get props => [folderId];
}

class ArchiveImageSelected extends ImageArchiveEvent {
  final String imageId;

  ArchiveImageSelected(this.imageId);

  @override
  List<Object> get props => [imageId];
}

class SortablesUpdated extends ImageArchiveEvent {
  final List<Sortable> sortables;

  SortablesUpdated(this.sortables);

  @override
  List<Object> get props => [sortables];
}
