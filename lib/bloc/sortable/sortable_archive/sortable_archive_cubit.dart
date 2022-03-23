import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';

part 'sortable_archive_state.dart';

class SortableArchiveCubit<T extends SortableData>
    extends Cubit<SortableArchiveState<T>> {
  late final StreamSubscription _sortableSubscription;
  final bool Function(Sortable<T>)? visibilityFilter;
  final bool showFolders;

  SortableArchiveCubit({
    required SortableBloc sortableBloc,
    String initialFolderId = '',
    this.visibilityFilter,
    this.showFolders = true,
  }) : super(_initialState<T>(
          sortableBloc.state,
          initialFolderId,
          visibilityFilter,
          showFolders,
        )) {
    _sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        sortablesUpdated(sortableState.sortables);
      }
    });
  }

  void sortablesUpdated(Iterable<Sortable> sortables) {
    emit(
      _stateFromSortables<T>(
        sortables: sortables,
        initialFolderId: state.initialFolderId,
        currentFolderId: state.currentFolderId,
        visibilityFilter: visibilityFilter,
        selected: state.selected,
        showFolder: showFolders,
      ),
    );
  }

  void navigateUp() {
    final currentFolder = state.allById[state.currentFolderId];
    emit(
      SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: currentFolder?.groupId ?? '',
        initialFolderId: state.initialFolderId,
      ),
    );
  }

  void sortableSelected(Sortable<T> selected) {
    emit(
      SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: state.currentFolderId,
        selected: selected,
        initialFolderId: state.initialFolderId,
      ),
    );
  }

  void folderChanged(String folderId) {
    emit(
      SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: folderId,
        initialFolderId: state.initialFolderId,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sortableSubscription.cancel();
    return super.close();
  }

  static SortableArchiveState<T> _initialState<T extends SortableData>(
    SortableState sortableState,
    String initialFolderId,
    bool Function(Sortable<T>)? visibilityFilter,
    bool showFolder,
  ) =>
      _stateFromSortables(
        sortables: sortableState is SortablesLoaded
            ? sortableState.sortables
            : <Sortable<SortableData>>[],
        initialFolderId: initialFolderId,
        currentFolderId: initialFolderId,
        visibilityFilter: visibilityFilter,
        showFolder: showFolder,
      );

  static SortableArchiveState<T> _stateFromSortables<T extends SortableData>({
    required Iterable<Sortable> sortables,
    required String initialFolderId,
    required String currentFolderId,
    bool Function(Sortable<T>)? visibilityFilter,
    Sortable<T>? selected,
    required bool showFolder,
  }) {
    final sortableArchive = sortables
        .whereType<Sortable<T>>()
        .where((s) => showFolder || !s.isGroup)
        .where(visibilityFilter ?? (_) => true);
    final allByFolder = showFolder
        ? groupBy<Sortable<T>, String>(sortableArchive, (s) => s.groupId)
        : {initialFolderId: sortableArchive.toList()};
    final allById = {for (var s in sortableArchive) s.id: s};
    return SortableArchiveState<T>(
      allByFolder,
      allById,
      currentFolderId: currentFolderId,
      selected: selected,
      initialFolderId: initialFolderId,
    );
  }
}
