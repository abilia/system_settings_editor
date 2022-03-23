part of 'sortable_bloc.dart';

abstract class SortableEvent extends Equatable {
  const SortableEvent();
  @override
  List<Object> get props => [];
}

class LoadSortables extends SortableEvent {
  final bool initDefaults;

  const LoadSortables({this.initDefaults = false});
  @override
  String toString() => 'LoadSortables';
}

class ImageArchiveImageAdded extends SortableEvent {
  final String imageId;
  final String imagePath;

  const ImageArchiveImageAdded(this.imageId, this.imagePath);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [imageId, imagePath];
}

class PhotoAdded extends SortableEvent {
  final String imageId;
  final String imagePath;
  final String name;
  final String folderId;
  final Set<String> tags;

  const PhotoAdded(
    this.imageId,
    this.imagePath,
    this.name,
    this.folderId, {
    this.tags = const {},
  });

  @override
  bool get stringify => true;

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
  bool get stringify => true;

  @override
  List<Object> get props => [sortables];
}

class SortableUpdated extends SortablesUpdated {
  SortableUpdated(Sortable sortable) : super([sortable]);
}
