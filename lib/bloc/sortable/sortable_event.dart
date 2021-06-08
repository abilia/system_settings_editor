// @dart=2.9

part of 'sortable_bloc.dart';

abstract class SortableEvent extends Equatable {
  const SortableEvent();
  @override
  List<Object> get props => [];
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
  bool get stringify => true;

  @override
  List<Object> get props => [imageId, imagePath];
}

class SortableUpdated extends SortableEvent {
  final Sortable sortable;

  SortableUpdated(this.sortable);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [sortable];
}
