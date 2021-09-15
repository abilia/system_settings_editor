part of 'sortable_bloc.dart';

abstract class SortableState extends Equatable {
  const SortableState();
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

  bool hasSortableOfType<T extends SortableData>() => false;
}

class SortablesNotLoaded extends SortableState {}

class SortablesLoaded extends SortableState {
  final Iterable<Sortable> sortables;

  const SortablesLoaded({
    required this.sortables,
  });

  @override
  bool hasSortableOfType<T extends SortableData>() =>
      sortables.whereType<Sortable<T>>().isNotEmpty;

  @override
  List<Object> get props => [sortables];
}

class SortablesLoadedFailed extends SortableState {}
