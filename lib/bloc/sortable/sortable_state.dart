part of 'sortable_bloc.dart';

abstract class SortableState extends Equatable {
  const SortableState();
  @override
  List<Object> get props => [];
}

class SortablesNotLoaded extends SortableState {
  @override
  List<Object> get props => [];
}

class SortablesLoaded extends SortableState {
  final Iterable<Sortable> sortables;

  const SortablesLoaded(this.sortables);

  @override
  List<Object> get props => [sortables];

  @override
  String toString() => 'SortablesLoaded { sortables: $sortables }';
}

class SortablesLoadedFailed extends SortableState {}
