part of 'sortable_archive_cubit.dart';

class SortableArchiveState<T extends SortableData> extends Equatable {
  final List<Sortable<T>> sortableArchive;
  final String currentFolderId;
  final String initialFolderId;
  final Sortable<T>? selected;
  final String searchValue;
  final bool showSearch;
  final bool showFolders;
  final bool Function(Sortable<T>)? visibilityFilter;

  const SortableArchiveState(
    this.sortableArchive, {
    this.currentFolderId = '',
    this.initialFolderId = '',
    this.selected,
    this.searchValue = '',
    this.showSearch = false,
    this.showFolders = true,
    this.visibilityFilter,
  });

  factory SortableArchiveState.fromSortables({
    required Iterable<Sortable> sortables,
    required String initialFolderId,
    required String currentFolderId,
    required bool showFolders,
    required bool showSearch,
    bool Function(Sortable<T>)? visibilityFilter,
    Sortable<T>? selected,
  }) {
    final sortableArchive = sortables
        .whereType<Sortable<T>>()
        .where((s) => showFolders || !s.isGroup)
        .where(visibilityFilter ?? (_) => true)
        .toList();
    return SortableArchiveState(
      sortableArchive,
      currentFolderId: currentFolderId,
      selected: selected,
      initialFolderId: initialFolderId,
      showSearch: showSearch,
      showFolders: showFolders,
      visibilityFilter: visibilityFilter,
    );
  }

  SortableArchiveState<T> copyWith({
    String? searchValue,
    bool? showSearch,
  }) =>
      SortableArchiveState(
        sortableArchive,
        currentFolderId: currentFolderId,
        initialFolderId: initialFolderId,
        selected: selected,
        searchValue: searchValue ?? this.searchValue,
        showSearch: showSearch ?? this.showSearch,
        showFolders: showFolders,
        visibilityFilter: visibilityFilter,
      );

  bool get isSelected => selected != null;

  bool get isAtRoot =>
      currentFolderId.isEmpty || currentFolderId == initialFolderId;

  bool get isAtRootAndNoSelection => isAtRoot && !isSelected;

  Map<String, List<Sortable<T>>> get allByFolder => showFolders
      ? groupBy<Sortable<T>, String>(sortableArchive, (s) => s.groupId)
      : {initialFolderId: sortableArchive.toList()};

  Map<String, Sortable<T>> get allById =>
      {for (var s in sortableArchive) s.id: s};

  List<Sortable<T>> get currentFolderSorted =>
      (allByFolder[currentFolderId] ?? [])
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Sortable<T>> allFilteredAndSorted(Translated t) {
    if (searchValue.isEmpty) return [];
    return sortableArchive
        .where((s) =>
            !s.isGroup && s.data.title(t).toLowerCase().contains(searchValue))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  String title(Translated translate, {bool onlyFolders = false}) =>
      (isSelected && !onlyFolders ? selected : allById[currentFolderId])
          ?.data
          .title(translate) ??
      '';

  String folderTitle(Translated translate) =>
      allById[currentFolderId]?.data.title(translate) ?? '';

  @override
  List<Object?> get props => [
        sortableArchive,
        currentFolderId,
        initialFolderId,
        selected,
        searchValue,
        showSearch,
        showFolders,
        visibilityFilter,
      ];

  @override
  bool get stringify => true;
}
