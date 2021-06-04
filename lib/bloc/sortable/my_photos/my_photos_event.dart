// @dart=2.9

part of 'my_photos_bloc.dart';

abstract class MyPhotosEvent extends Equatable {}

class SortablesArrived extends MyPhotosEvent {
  final Iterable<Sortable> sortables;

  SortablesArrived(this.sortables);

  @override
  List<Object> get props => [sortables];

  @override
  bool get stringify => true;
}

class PhotoAdded extends MyPhotosEvent {
  final String imageId;
  final String imagePath;
  final String name;

  PhotoAdded(
    this.imageId,
    this.imagePath,
    this.name,
  );

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        imageId,
        imagePath,
        name,
      ];
}
