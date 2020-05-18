import 'dart:async';
import 'dart:collection';

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

  final Queue<SyncEvent> _syncQueue = Queue<SyncEvent>();

  @override
  void add(SyncEvent event) {
    if (state is SyncUnavailible) {
      if (!_syncQueue.contains(event)) {
        // queueing event
        _syncQueue.add(event);
      } // else dropping event
    } else {
      super.add(event);
    }
  }

  @override
  SyncState get initialState => SyncInitial();

  @override
  Stream<SyncState> mapEventToState(
    SyncEvent event,
  ) async* {
    yield SyncPending();
    if (!await _sync(event)) {
      yield SyncFailed();
      Future.delayed(1.minutes(), () => super.add(event));
      return;
    }
    // Throttle sync to queue up potential fast incoming event
    await Future.delayed(3.seconds());
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
    }
    return true;
  }
}
