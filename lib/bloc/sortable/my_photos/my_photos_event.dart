part of 'my_photos_bloc.dart';

abstract class MyPhotosEvent extends Equatable {
  const MyPhotosEvent();
}

class SortablesArrived extends MyPhotosEvent {
  final Iterable<Sortable> sortables;

  const SortablesArrived(this.sortables);

  @override
  List<Object> get props => [sortables];

  @override
  bool get stringify => true;
}

class PhotoAdded extends MyPhotosEvent {
  final String imageId;
  final String imagePath;
  final String name;
  final String? folderId;

  const PhotoAdded(
    this.imageId,
    this.imagePath,
    this.name, {
    this.folderId,
  });

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        imageId,
        imagePath,
        name,
      ];
}
