part of 'sortable_archive_bloc.dart';

class SortableArchiveState<T extends SortableData> extends Equatable {
  final Map<String, List<Sortable<T>>> allByFolder;
  final Map<String, Sortable<T>> allById;
  final String currentFolderId;
  final String initialFolderId;
  final Sortable<T>? selected;

  const SortableArchiveState(
    this.allByFolder,
    this.allById, {
    this.currentFolderId = '',
    this.initialFolderId = '',
    this.selected,
  });

  SortableArchiveState<T> copyWith({
    Map<String, List<Sortable<T>>>? allByFolder,
    Map<String, Sortable<T>>? allById,
    String? currentFolderId,
    String? initialFolderId,
    Sortable<T>? selected,
  }) =>
      SortableArchiveState(
        allByFolder ?? this.allByFolder,
        allById ?? this.allById,
        currentFolderId: currentFolderId ?? this.currentFolderId,
        initialFolderId: initialFolderId ?? this.initialFolderId,
        selected: selected ?? this.selected,
      );

  bool get isSelected => selected != null;
  bool get isAtRoot =>
      currentFolderId.isEmpty || currentFolderId == initialFolderId;
  bool get isAtRootAndNoSelection => isAtRoot && !isSelected;
  bool get inMyPhotos {
    final s = allById[currentFolderId]?.data;
    return s is ImageArchiveData && s.myPhotos;
  }

  @override
  List<Object?> get props => [
        allByFolder,
        allById,
        currentFolderId,
        initialFolderId,
        selected,
      ];

  @override
  bool get stringify => true;
}
