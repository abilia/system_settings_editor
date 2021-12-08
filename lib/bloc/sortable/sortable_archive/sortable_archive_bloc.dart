import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'sortable_archive_event.dart';
part 'sortable_archive_state.dart';

class SortableArchiveBloc<T extends SortableData>
    extends Bloc<SortableArchiveEvent, SortableArchiveState<T>> {
  late final StreamSubscription sortableSubscription;
  final bool Function(Sortable<T>)? visibilityFilter;

  SortableArchiveBloc({
    required SortableBloc sortableBloc,
    String initialFolderId = '',
    this.visibilityFilter,
  }) : super(_initialState<T>(
          sortableBloc.state,
          initialFolderId,
          visibilityFilter,
        )) {
    sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        add(SortablesUpdated(sortableState.sortables));
      }
    });
  }

  static SortableArchiveState<T> _initialState<T extends SortableData>(
    SortableState sortableState,
    String initialFolderId,
    bool Function(Sortable<T>)? visibilityFilter,
  ) =>
      _stateFromSortabled(
        sortables: sortableState is SortablesLoaded
            ? sortableState.sortables
            : <Sortable<SortableData>>[],
        initialFolderId: initialFolderId,
        currentFolderId: initialFolderId,
        visibilityFilter: visibilityFilter,
      );

  static SortableArchiveState<T> _stateFromSortabled<T extends SortableData>({
    required Iterable<Sortable<SortableData>> sortables,
    required String initialFolderId,
    required String currentFolderId,
    bool Function(Sortable<T>)? visibilityFilter,
    Sortable<T>? selected,
  }) {
    final sortableArchive = sortables
        .whereType<Sortable<T>>()
        .where(visibilityFilter ?? (_) => true);
    final allByFolder =
        groupBy<Sortable<T>, String>(sortableArchive, (s) => s.groupId);
    final allById = {for (var s in sortableArchive) s.id: s};
    final currentFolder = allById[currentFolderId];
    return SortableArchiveState<T>(
      allByFolder,
      allById,
      currentFolderId: currentFolder?.id ?? '',
      selected: selected,
      initialFolderId: initialFolderId,
    );
  }

  @override
  Stream<SortableArchiveState<T>> mapEventToState(
    SortableArchiveEvent event,
  ) async* {
    if (event is SortablesUpdated) {
      yield _stateFromSortabled<T>(
        sortables: event.sortables,
        initialFolderId: state.initialFolderId,
        currentFolderId: state.currentFolderId,
        visibilityFilter: visibilityFilter,
        selected: state.selected,
      );
    } else if (event is FolderChanged) {
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: event.folderId,
        initialFolderId: state.initialFolderId,
      );
    } else if (event is NavigateUp) {
      final currentFolder = state.allById[state.currentFolderId];
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: currentFolder?.groupId ?? '',
        initialFolderId: state.initialFolderId,
      );
    } else if (event is SortableSelected<T>) {
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: state.currentFolderId,
        selected: event.selected,
        initialFolderId: state.initialFolderId,
      );
    } else if (event is InitialFolder) {
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        initialFolderId: event.folderId,
        currentFolderId: event.folderId,
      );
    }
  }
}
