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

  SortableArchiveBloc({required SortableBloc sortableBloc})
      : super(SortableArchiveState({}, {})) {
    sortableSubscription = sortableBloc.stream.listen((sortableState) {
      if (sortableState is SortablesLoaded) {
        add(SortablesUpdated(sortableState.sortables));
      }
    });
    final sortableState = sortableBloc.state;
    if (sortableState is SortablesLoaded) {
      add(SortablesUpdated(sortableState.sortables));
    }
  }

  @override
  Stream<SortableArchiveState<T>> mapEventToState(
    SortableArchiveEvent event,
  ) async* {
    if (event is SortablesUpdated) {
      final sortableArchive = event.sortables.whereType<Sortable<T>>();
      final allByFolder =
          groupBy<Sortable<T>, String>(sortableArchive, (s) => s.groupId);
      final allById = {for (var s in sortableArchive) s.id: s};
      final currentFolder = allById[state.currentFolderId];
      yield SortableArchiveState<T>(
        allByFolder,
        allById,
        currentFolderId: currentFolder?.id ?? '',
        selected: state.selected,
      );
    } else if (event is FolderChanged) {
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: event.folderId,
      );
    } else if (event is NavigateUp) {
      final currentFolder = state.allById[state.currentFolderId];
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: currentFolder?.groupId ?? '',
      );
    } else if (event is SortableSelected<T>) {
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolderId: state.currentFolderId,
        selected: event.selected,
      );
    }
  }
}
