import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';

import 'package:seagull/repository/all.dart';

part 'sync_state.dart';
part 'sync_delays.dart';

enum SyncEvent {
  activitySaved,
  fileSaved,
  sortableSaved,
  genericSaved,
}

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
  }) : super(const SyncDone());

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
    yield const SyncPending();
    if (!await _sync(event)) {
      yield const SyncFailed();
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
      yield const SyncDone();
    }
  }

  Future<bool> _sync(SyncEvent event) async {
    switch (event) {
      case SyncEvent.activitySaved:
        return activityRepository.synchronize();
      case SyncEvent.fileSaved:
        return userFileRepository.synchronize();
      case SyncEvent.sortableSaved:
        return sortableRepository.synchronize();
      case SyncEvent.genericSaved:
        return genericRepository.synchronize();
    }
  }
}
