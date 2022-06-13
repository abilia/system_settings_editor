part of 'sortable_bloc.dart';

abstract class SortableEvent extends Equatable {
  const SortableEvent();
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class LoadSortables extends SortableEvent {
  final bool initDefaults;

  const LoadSortables({this.initDefaults = false});
}

class ImageArchiveImageAdded extends SortableEvent {
  final String imageId, imagePath;

  const ImageArchiveImageAdded(this.imageId, this.imagePath);

  @override
  List<Object> get props => [imageId, imagePath];
}

class PhotoAdded extends SortableEvent {
  final String imageId, imagePath, name, folderId;
  final Set<String> tags;

  const PhotoAdded(
    this.imageId,
    this.imagePath,
    this.name,
    this.folderId, {
    this.tags = const {},
  });

  @override
  List<Object> get props => [
        imageId,
        imagePath,
        name,
        folderId,
      ];
}

class SortablesUpdated extends SortableEvent {
  final List<Sortable> sortables;

  const SortablesUpdated(this.sortables);

  @override
  List<Object> get props => [sortables];
}

class SortableUpdated extends SortablesUpdated {
  SortableUpdated(Sortable sortable) : super([sortable]);
}
