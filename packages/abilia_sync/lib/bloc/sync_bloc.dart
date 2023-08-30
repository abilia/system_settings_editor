import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/data_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull_clock/clock_cubit.dart';

part 'sync_event.dart';

part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final PushCubit pushCubit;
  final LicenseCubit licenseCubit;

  final DataRepository activityRepository;
  final DataRepository userFileRepository;
  final DataRepository sortableRepository;
  final DataRepository genericRepository;
  final LastSyncDb lastSyncDb;
  final ClockCubit clockCubit;
  final Duration retryDelay;
  final Duration syncDelay;

  final _log = Logger('SyncBloc');

  late StreamSubscription _pushSubscription;

  bool get hasSynced => state is SyncDone;

  SyncBloc({
    required this.pushCubit,
    required this.licenseCubit,
    required this.activityRepository,
    required this.userFileRepository,
    required this.sortableRepository,
    required this.genericRepository,
    required this.retryDelay,
    required this.syncDelay,
    required this.lastSyncDb,
    required this.clockCubit,
  }) : super(Syncing(lastSynced: lastSyncDb.getLastSyncTime())) {
    _pushSubscription =
        pushCubit.stream.listen((message) => add(const SyncAll()));
    on<SyncActivities>(_trySync, transformer: bufferTimer(syncDelay));
    on<SyncFiles>(_trySync, transformer: bufferTimer(syncDelay));
    on<SyncSortables>(_trySync, transformer: bufferTimer(syncDelay));
    on<SyncGenerics>(_trySync, transformer: bufferTimer(syncDelay));
    on<SyncAll>(_trySync, transformer: bufferTimer(syncDelay));
  }

  Future<bool> hasDirty() async {
    return await activityRepository.db.countAllDirty() > 0 ||
        await userFileRepository.db.countAllDirty() > 0 ||
        await sortableRepository.db.countAllDirty() > 0 ||
        await genericRepository.db.countAllDirty() > 0;
  }

  Future _trySync(
    SyncEvent event,
    Emitter emit,
  ) async {
    try {
      emit(Syncing(lastSynced: state.lastSynced));
      final didFetchData = await _sync(event);
      var lastSynced = state.lastSynced;
      if (licenseCubit.validLicense) {
        lastSynced = clockCubit.state;
        await lastSyncDb.setSyncTime(lastSynced);
      }
      if (isClosed) return;
      emit(Synced(lastSynced: lastSynced, didFetchData: didFetchData));
    } catch (error) {
      emit(SyncedFailed(lastSynced: state.lastSynced));
      _log.info('could not sync $event, retries in $retryDelay');
      await Future.delayed(retryDelay);
      if (isClosed) return;
      _log.info('retrying $event');
      add(event);
    }
  }

  Future<bool> _sync(SyncEvent event) async {
    switch (event.runtimeType) {
      case SyncAll:
        return _syncAll();
      case SyncActivities:
        if (licenseCubit.validLicense) return activityRepository.synchronize();
        return false;
      case SyncFiles:
        return userFileRepository.synchronize();
      case SyncSortables:
        return sortableRepository.synchronize();
      case SyncGenerics:
        return genericRepository.synchronize();
    }
    throw Exception('Unknown event type $event');
  }

  Future<bool> _syncAll() async {
    final results = await Future.wait([
      if (licenseCubit.validLicense) activityRepository.synchronize(),
      userFileRepository.synchronize(),
      sortableRepository.synchronize(),
      genericRepository.synchronize(),
    ]);
    return results.any((synced) => synced);
  }

  @override
  Future<void> close() async {
    await _pushSubscription.cancel();
    return super.close();
  }
}

EventTransformer<Event> bufferTimer<Event>(Duration betweenSync) =>
    (events, mapper) => events
        .throttleTime(betweenSync, trailing: true, leading: false)
        .asyncExpand(mapper); // sequential
