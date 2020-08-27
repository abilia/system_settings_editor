import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'image_archive_event.dart';
part 'image_archive_state.dart';

class SortableArchiveBloc<T extends SortableData>
    extends Bloc<SortableArchiveEvent, SortableArchiveState<T>> {
  final SortableBloc sortableBloc;
  StreamSubscription sortableSubscription;

  SortableArchiveBloc({@required this.sortableBloc})
      : super(SortableArchiveState({}, {}, null)) {
    sortableSubscription = sortableBloc.listen((sortableState) {
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
      final sortableArchive =
          event.sortables.whereType<Sortable<T>>();
      final allByFolder = groupBy<Sortable<T>, String>(
          sortableArchive, (s) => s.groupId);
      final allById = {for (var s in sortableArchive) s.id: s};
      final currentFolder = allById[state.currentFolderId];
      yield SortableArchiveState<T>(
        allByFolder,
        allById,
        currentFolder?.id,
      );
    } else if (event is FolderChanged) {
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        event.folderId,
      );
    } else if (event is NavigateUp) {
      final currentFolder = state.allById[state.currentFolderId];
      yield SortableArchiveState<T>(
        state.allByFolder,
        state.allById,
        currentFolder.groupId,
      );
    }
  }
}
