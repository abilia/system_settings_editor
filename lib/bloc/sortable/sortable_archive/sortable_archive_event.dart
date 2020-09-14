part of 'sortable_archive_bloc.dart';

abstract class SortableArchiveEvent extends Equatable {
  const SortableArchiveEvent();
}

class FolderChanged extends SortableArchiveEvent {
  final String folderId;

  FolderChanged(this.folderId);

  @override
  List<Object> get props => [folderId];
}

class SortablesUpdated extends SortableArchiveEvent {
  final Iterable<Sortable> sortables;

  SortablesUpdated(this.sortables);

  @override
  List<Object> get props => [sortables];
}

class NavigateUp extends SortableArchiveEvent {
  @override
  List<Object> get props => [];
}
