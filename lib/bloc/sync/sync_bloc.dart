import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/repository/all.dart';

part 'sync_event.dart';
part 'sync_state.dart';
part 'sync_delays.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ActivityRepository activityRepository;
  final UserFileRepository userFileRepository;
  final SortableRepository sortableRepository;
  final GenericRepository genericRepository;
  final SyncDelays syncDelay;

  SyncBloc({
    required this.activityRepository,
    required this.userFileRepository,
    required this.sortableRepository,
    required this.syncDelay,
    required this.genericRepository,
  }) : super(SyncInitial());

  final Queue<SyncEvent> _syncQueue = Queue<SyncEvent>();

  @override
  void add(SyncEvent event) {
    if (state is SyncUnavailable) {
      if (!_syncQueue.contains(event)) {
        // queueing event
        _syncQueue.add(event);
      } // else dropping event
    } else {
      super.add(event);
    }
  }

  @override
  Stream<SyncState> mapEventToState(
    SyncEvent event,
  ) async* {
    yield SyncPending();
    if (!await _sync(event)) {
      yield SyncFailed();
      if (!_syncQueue.contains(event)) {
        _syncQueue.add(event);
      }
      Future.delayed(
          syncDelay.retryDelay, () => super.add(_syncQueue.removeFirst()));
      return;
    }
    // Throttle sync to queue up potential fast incoming event
    await Future.delayed(syncDelay.betweenSync);
    if (_syncQueue.isNotEmpty) {
      // dequeuing
      super.add(_syncQueue.removeFirst());
    } else {
      yield SyncDone();
    }
  }

  Future<bool> _sync(SyncEvent event) async {
    if (event is ActivitySaved) {
      return activityRepository.synchronize();
    } else if (event is FileSaved) {
      return userFileRepository.synchronize();
    } else if (event is SortableSaved) {
      return sortableRepository.synchronize();
    } else if (event is GenericSaved) {
      return genericRepository.synchronize();
    }

    return true;
  }
}
