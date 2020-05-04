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
  final SortableData imageData;

  ArchiveImageSelected(this.imageData);

  @override
  List<Object> get props => [imageData];
}

class SortablesUpdated extends ImageArchiveEvent {
  final Iterable<Sortable> sortables;

  SortablesUpdated(this.sortables);

  @override
  List<Object> get props => [sortables];
}

class NavigateUp extends ImageArchiveEvent {
  @override
  List<Object> get props => [];
}
