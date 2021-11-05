part of 'sortable_archive_bloc.dart';

abstract class SortableArchiveEvent extends Equatable {
  const SortableArchiveEvent();
}

class FolderChanged extends SortableArchiveEvent {
  final String folderId;

  const FolderChanged(this.folderId);

  @override
  List<Object> get props => [folderId];
}

class SortableSelected<T extends SortableData> extends SortableArchiveEvent {
  final Sortable<T> selected;

  const SortableSelected(this.selected);

  @override
  List<Object> get props => [selected];
}

class SortablesUpdated extends SortableArchiveEvent {
  final Iterable<Sortable> sortables;

  const SortablesUpdated(this.sortables);

  @override
  List<Object> get props => [sortables];
}

class NavigateUp extends SortableArchiveEvent {
  @override
  List<Object> get props => [];
}

class InitialFolder extends SortableArchiveEvent {
  final String folderId;

  const InitialFolder(this.folderId);

  @override
  List<Object> get props => [folderId];
}
