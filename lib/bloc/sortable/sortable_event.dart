part of 'sortable_bloc.dart';

abstract class SortableEvent {
  const SortableEvent();
}

class LoadSortables extends SortableEvent {
  @override
  String toString() => 'LoadSortables';
}

class ImageArchiveImageAdded extends SortableEvent {
  final String imageId;
  final String imagePath;

  ImageArchiveImageAdded(this.imageId, this.imagePath);
  @override
  String toString() =>
      'ImageArchiveImageAdded {imageId: $imageId, imagePath: $imagePath }';
}
