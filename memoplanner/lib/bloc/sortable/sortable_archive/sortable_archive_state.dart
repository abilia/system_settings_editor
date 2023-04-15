part of 'sortable_archive_cubit.dart';

class SortableArchiveState<T extends SortableData> extends Equatable {
  final List<Sortable<T>> sortableArchive;
  final String currentFolderId;
  final String initialFolderId;
  final Sortable<T>? selected;
  final String searchValue;
  final bool showFolders;

  // If true, only show images from my photos. If false, exclude images from my photos.
  final bool myPhotos;

  const SortableArchiveState(
    this.sortableArchive, {
    this.currentFolderId = '',
    this.initialFolderId = '',
    this.selected,
    this.searchValue = '',
    this.myPhotos = false,
    this.showFolders = true,
  });

  factory SortableArchiveState.fromSortables({
    required Iterable<Sortable> sortables,
    required String initialFolderId,
    required String currentFolderId,
    required bool showFolders,
    required bool myPhotos,
    required Sortable<T>? selected,
    bool Function(Sortable<T>)? visibilityFilter,
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
      showFolders: showFolders,
      myPhotos: myPhotos,
    );
  }

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
      (allByFolder[currentFolderId] ?? []).where(myPhotosFilter).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Sortable> get allMyPhotos {
    final myPhotosFolder = sortableArchive.getMyPhotosFolder();
    if (myPhotosFolder == null) {
      return [];
    }
    return [...?allByFolder[myPhotosFolder.id], myPhotosFolder];
  }

  bool myPhotosFilter(Sortable sortable) {
    return myPhotos ? isMyPhotos(sortable) : !isMyPhotos(sortable);
  }

  bool isMyPhotos(Sortable sortable) {
    final photoIds = allMyPhotos.map((s) => s.id).toList();
    return photoIds.contains(sortable.id);
  }

  List<Sortable<T>> allFilteredAndSorted(Translated t) {
    if (searchValue.isEmpty) return [];
    return sortableArchive
        .where((s) =>
            !s.isGroup &&
            s.data.title(t).toLowerCase().contains(searchValue) &&
            myPhotosFilter(s))
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
        showFolders,
        myPhotos,
      ];

  @override
  bool get stringify => true;
}
