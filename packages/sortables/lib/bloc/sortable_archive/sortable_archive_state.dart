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

  SortableArchiveState<T> copyWith({
    required Sortable<T>? selected,
    String? currentFolderId,
    String? initialFolderId,
    String? searchValue,
    bool? showFolders,
    bool? myPhotos,
  }) =>
      SortableArchiveState(
        this.sortableArchive,
        currentFolderId: currentFolderId ?? this.currentFolderId,
        initialFolderId: initialFolderId ?? this.initialFolderId,
        searchValue: searchValue ?? this.searchValue,
        myPhotos: myPhotos ?? this.myPhotos,
        showFolders: showFolders ?? this.showFolders,
        selected: selected,
      );

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
    return allInFolder(myPhotosFolder.id)..add(myPhotosFolder);
  }

  List<Sortable> allInFolder(String groupId) {
    final List<Sortable> sortables =
        sortableArchive.where((s) => s.groupId == groupId).toList();
    final folders = [...sortables.where((s) => s.isGroup)];
    for (final folder in folders) {
      sortables.addAll(allInFolder(folder.id));
    }
    return sortables;
  }

  bool myPhotosFilter(Sortable sortable) =>
      myPhotos ? isMyPhotos(sortable) : !isMyPhotos(sortable);

  bool isMyPhotos(Sortable sortable) =>
      allMyPhotos.map((s) => s.id).contains(sortable.id);

  List<Sortable<T>> allFilteredAndSorted() {
    if (searchValue.isEmpty) return [];
    return sortableArchive
        .where((s) =>
            !s.isGroup &&
            s.data.title().toLowerCase().contains(searchValue) &&
            myPhotosFilter(s))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  String title({bool onlyFolders = false}) =>
      (isSelected && !onlyFolders ? selected : allById[currentFolderId])
          ?.data
          .title() ??
      '';

  String folderTitle() => allById[currentFolderId]?.data.title() ?? '';

  List<Sortable<T>> folderPath() => [
        for (var folder = allById[currentFolderId];
            folder != null;
            folder = allById[folder.groupId])
          folder,
      ];

  String? breadCrumbPath() => !isAtRoot
      ? folderPath().reversed.map((e) => e.data.title()).join(' / ')
      : null;

  @override
  List<Object?> get props => [
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
