part of 'sortable_bloc.dart';

abstract class SortableState extends Equatable {
  const SortableState();
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class SortablesNotLoaded extends SortableState {}

class SortablesLoaded extends SortableState {
  final Iterable<Sortable> sortables;

  const SortablesLoaded({
    this.sortables,
  });

  @override
  List<Object> get props => [sortables];
}

class SortablesLoadedFailed extends SortableState {}
