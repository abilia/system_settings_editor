import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sortables/bloc/sortable_bloc.dart';
import 'package:sortables/models/sortable/all.dart';
import 'package:sortables/utils/extensions/sortables_extensions.dart';

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
    bool myPhotos = false,
  }) : super(
          SortableArchiveState.fromSortables(
            sortables: sortableBloc.state is SortablesLoaded
                ? (sortableBloc.state as SortablesLoaded).sortables
                : <Sortable<SortableData>>[],
            initialFolderId: initialFolderId,
            currentFolderId: initialFolderId,
            visibilityFilter: visibilityFilter,
            showFolders: showFolders,
            selected: null,
            myPhotos: myPhotos,
          ),
        ) {
    _sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        sortablesUpdated(
          sortableState.sortables,
          visibilityFilter: visibilityFilter,
        );
      }
    });
  }

  void sortablesUpdated(
    Iterable<Sortable> sortables, {
    bool Function(Sortable<T>)? visibilityFilter,
  }) {
    emit(
      SortableArchiveState.fromSortables(
        sortables: sortables,
        initialFolderId: state.initialFolderId,
        currentFolderId: state.currentFolderId,
        visibilityFilter: visibilityFilter,
        selected: state.selected,
        showFolders: state.showFolders,
        myPhotos: state.myPhotos,
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
        myPhotos: state.myPhotos,
      ),
    );
  }

  void sortableSelected(Sortable<T>? selected) =>
      emit(state.copyWith(selected: selected));

  void folderChanged(String folderId) =>
      emit(state.copyWith(selected: state.selected, currentFolderId: folderId));

  void unselect() => emit(state.copyWith(selected: null));

  void searchValueChanged(String searchValue) =>
      emit(state.copyWith(selected: state.selected, searchValue: searchValue));

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