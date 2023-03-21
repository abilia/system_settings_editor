import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/i18n/all.dart';
import 'package:memoplanner/models/all.dart';

part 'sortable_archive_state.dart';

class SortableArchiveCubit<T extends SortableData>
    extends Cubit<SortableArchiveState<T>> {
  late final StreamSubscription _sortableSubscription;
  final SortableBloc sortableBloc;

  SortableArchiveCubit({
    required this.sortableBloc,
    String initialFolderId = '',
    bool Function(Sortable<T>)? visibilityFilter,
    bool showFolders = true,
  }) : super(SortableArchiveState.fromSortables(
          sortables: sortableBloc.state is SortablesLoaded
              ? (sortableBloc.state as SortablesLoaded).sortables
              : <Sortable<SortableData>>[],
          initialFolderId: initialFolderId,
          currentFolderId: initialFolderId,
          visibilityFilter: visibilityFilter,
          showFolders: showFolders,
          showSearch: false,
        )) {
    _sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        sortablesUpdated(sortableState.sortables);
      }
    });
  }

  void sortablesUpdated(Iterable<Sortable> sortables) {
    emit(
      SortableArchiveState.fromSortables(
        sortables: sortables,
        initialFolderId: state.initialFolderId,
        currentFolderId: state.currentFolderId,
        visibilityFilter: state.visibilityFilter,
        selected: state.selected,
        showFolders: state.showFolders,
        showSearch: state.showSearch,
      ),
    );
  }

  void navigateUp() {
    final currentFolder = state.allById[state.currentFolderId];
    emit(
      SortableArchiveState<T>(
        state.sortableArchive,
        currentFolderId: currentFolder?.groupId ?? '',
        initialFolderId: state.initialFolderId,
      ),
    );
  }

  void sortableSelected(Sortable<T>? selected) {
    emit(
      SortableArchiveState<T>(
        state.sortableArchive,
        currentFolderId: state.currentFolderId,
        selected: selected,
        initialFolderId: state.initialFolderId,
        searchValue: state.searchValue,
        showSearch: state.showSearch,
        showFolders: state.showFolders,
      ),
    );
  }

  void folderChanged(String folderId) {
    emit(
      SortableArchiveState<T>(
        state.sortableArchive,
        currentFolderId: folderId,
        initialFolderId: state.initialFolderId,
        showSearch: state.showSearch,
        searchValue: state.searchValue,
        showFolders: state.showFolders,
        visibilityFilter: state.visibilityFilter,
      ),
    );
  }

  void setShowSearch(bool showSearch) =>
      emit(state.copyWith(searchValue: '', showSearch: showSearch));

  void searchValueChanged(String searchValue) =>
      emit(state.copyWith(searchValue: searchValue));

  void reorder(SortableReorderDirection direction) {
    final selectedId = state.selected?.id;
    if (selectedId == null) return;
    final sortables = state.currentFolderSorted;
    final sortableIndex = sortables.indexWhere((q) => q.id == selectedId);
    final swapWithIndex = direction == SortableReorderDirection.up
        ? sortableIndex - 1
        : sortableIndex + 1;
    if (sortableIndex >= 0 &&
        sortableIndex < sortables.length &&
        swapWithIndex >= 0 &&
        swapWithIndex < sortables.length) {
      final sortable = sortables[sortableIndex];
      final sortableSwap = sortables[swapWithIndex];
      final newSortOrder = sortableSwap.sortOrder;
      sortableBloc.add(SortablesUpdated([
        sortableSwap.copyWith(sortOrder: sortable.sortOrder),
        sortable.copyWith(sortOrder: newSortOrder),
      ]));
    }
  }

  void delete() {
    final selectedId = state.selected?.id;
    if (selectedId == null) return;
    final sortables = state.currentFolderSorted;
    final sortableIndex = sortables.indexWhere((q) => q.id == selectedId);
    sortableBloc.add(
        SortablesUpdated([sortables[sortableIndex].copyWith(deleted: true)]));
  }

  @override
  Future<void> close() async {
    await _sortableSubscription.cancel();
    return super.close();
  }
}
