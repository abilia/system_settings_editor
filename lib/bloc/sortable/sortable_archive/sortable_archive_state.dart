// @dart=2.9

part of 'sortable_archive_bloc.dart';

class SortableArchiveState<T extends SortableData> extends Equatable {
  final Map<String, Iterable<Sortable<T>>> allByFolder;
  final Map<String, Sortable<T>> allById;
  final String currentFolderId;
  final Sortable<T> selected;

  SortableArchiveState(
    this.allByFolder,
    this.allById, {
    this.currentFolderId = '',
    this.selected,
  });

  SortableArchiveState<T> copyWith({
    Map<String, Iterable<Sortable<T>>> allByFolder,
    Map<String, Sortable<T>> allById,
    String currentFolderId,
    Sortable<T> selected,
  }) =>
      SortableArchiveState(
        allByFolder ?? this.allByFolder,
        allById ?? this.allById,
        currentFolderId: currentFolderId ?? this.currentFolderId,
        selected: selected ?? this.selected,
      );

  bool get isSelected => selected != null;
  bool get isAtRoot => currentFolderId.isEmpty;
  bool get isAtRootAndNoSelection => isAtRoot && !isSelected;

  @override
  List<Object> get props => [
        allByFolder,
        allById,
        currentFolderId,
        selected,
      ];

  @override
  bool get stringify => true;
}
