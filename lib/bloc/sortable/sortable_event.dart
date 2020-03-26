part of 'sortable_bloc.dart';

abstract class SortableEvent {
  const SortableEvent();
}

class LoadSortables extends SortableEvent {}

class ImageArchiveImageAdded extends SortableEvent {
  final String imageId;
  final String imagePath;

  ImageArchiveImageAdded(this.imageId, this.imagePath);
}
