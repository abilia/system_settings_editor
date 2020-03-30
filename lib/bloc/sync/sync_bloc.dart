import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ActivityRepository activityRepository;
  final UserFileRepository userFileRepository;
  final SortableRepository sortableRepository;

  SyncBloc({
    @required this.activityRepository,
    @required this.userFileRepository,
    @required this.sortableRepository,
  });

  @override
  SyncState get initialState => SyncInitial();

  @override
  Stream<SyncState> mapEventToState(
    SyncEvent event,
  ) async* {
    if (event is ActivitySaved) {
      yield* await _mapActivitySavedToState();
    }
    if (event is FileSaved) {
      yield* _mapFileSavedToState();
    }
    if (event is SortableSaved) {
      yield* _mapSortableSavedToState();
    }
  }

  Stream<SyncState> _mapActivitySavedToState() async* {
    yield SyncPending();
    final syncResult = await activityRepository.synchronize();
    if (syncResult) {
      yield SyncDone();
    } else {
      yield SyncFailed();
      Future.delayed(1.minutes(), () => add(ActivitySaved()));
    }
  }

  Stream<SyncState> _mapFileSavedToState() async* {
    yield SyncPending();
    print('Sync user files');
    final syncResult = await userFileRepository.synchronize();
    if (syncResult) {
      yield SyncDone();
    } else {
      yield SyncFailed();
      Future.delayed(1.minutes(), () => add(FileSaved()));
    }
  }

  Stream<SyncState> _mapSortableSavedToState() async* {
    yield SyncPending();
    print('Sync sortables');
    final syncResult = await sortableRepository.synchronize();
    if (syncResult) {
      yield SyncDone();
    } else {
      yield SyncFailed();
      Future.delayed(1.minutes(), () => add(SortableSaved()));
    }
  }
}
