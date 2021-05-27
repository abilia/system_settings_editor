part of 'my_photos_bloc.dart';

abstract class MyPhotosEvent {}

class SortablesArrived extends MyPhotosEvent {
  final Iterable<Sortable> sortables;

  SortablesArrived(this.sortables);
}
