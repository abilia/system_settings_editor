import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/logging.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'sync_event.dart';

class SyncBloc extends Bloc<SyncEvent, dynamic> {
  final ActivityRepository activityRepository;
  final UserFileRepository userFileRepository;
  final SortableRepository sortableRepository;
  final GenericRepository genericRepository;
  final SyncDelays syncDelay;
  final _log = Logger('SyncBloc');

  SyncBloc({
    required this.activityRepository,
    required this.userFileRepository,
    required this.sortableRepository,
    required this.syncDelay,
    required this.genericRepository,
  }) : super(null) {
    on<ActivitySaved>(_trySync, transformer: bufferTimer(syncDelay));
    on<FileSaved>(_trySync, transformer: bufferTimer(syncDelay));
    on<SortableSaved>(_trySync, transformer: bufferTimer(syncDelay));
    on<GenericSaved>(_trySync, transformer: bufferTimer(syncDelay));
  }

  Future _trySync(
    SyncEvent event,
    Emitter emit,
  ) async {
    if (!await _sync(event)) {
      _log.info('could not sync $event, retries in ${syncDelay.retryDelay}');
      await Future.delayed(syncDelay.retryDelay);
      _log.info('retrying $event');
      add(event);
    }
  }

  Future<bool> _sync(SyncEvent event) async {
    switch (event.runtimeType) {
      case ActivitySaved:
        return activityRepository.synchronize();
      case FileSaved:
        return userFileRepository.synchronize();
      case SortableSaved:
        return sortableRepository.synchronize();
      case GenericSaved:
        return genericRepository.synchronize();
    }
    throw Exception('Unknown event type $event');
  }
}

EventTransformer<Event> bufferTimer<Event>(SyncDelays syncDelays) =>
    (events, mapper) => events
        .throttleTime(syncDelays.betweenSync, trailing: true, leading: false)
        .asyncExpand(mapper); // sequential
