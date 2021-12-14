import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'sync_event.dart';

class SyncBloc extends Bloc<SyncEvent, dynamic> {
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
  }) : super(null) {
    on<ActivitySaved>(_mapEventToState, transformer: bufferTimer(syncDelay));
    on<FileSaved>(_mapEventToState, transformer: bufferTimer(syncDelay));
    on<SortableSaved>(_mapEventToState, transformer: bufferTimer(syncDelay));
    on<GenericSaved>(_mapEventToState, transformer: bufferTimer(syncDelay));
  }

  Future _mapEventToState(
    SyncEvent event,
    Emitter emit,
  ) async {
    if (!await _sync(event)) {
      Future.delayed(syncDelay.retryDelay);
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
        .throttleTime(syncDelays.betweenSync, trailing: true, leading: true)
        .asyncExpand(mapper); // sequential
