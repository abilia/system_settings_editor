import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:rxdart/rxdart.dart';

part 'sync_event.dart';

part 'sync_state.dart';

class SyncBloc extends Bloc<Object, SyncState> {
  final PushCubit pushCubit;
  final LicenseCubit licenseCubit;

  final ActivityRepository activityRepository;
  final UserFileRepository userFileRepository;
  final SortableRepository sortableRepository;
  final GenericRepository genericRepository;
  final LastSyncDb lastSyncDb;
  final ClockBloc clockBloc;
  final SyncDelays syncDelay;
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
    required this.syncDelay,
    required this.lastSyncDb,
    required this.clockBloc,
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
    Object event,
    Emitter emit,
  ) async {
    try {
      emit(Syncing(lastSynced: state.lastSynced));
      final didFetchData = await _sync(event);
      var lastSynced = state.lastSynced;
      if (licenseCubit.validLicense) {
        lastSynced = clockBloc.state;
        await lastSyncDb.setSyncTime(lastSynced);
      }
      emit(Synced(lastSynced: lastSynced, didFetchData: didFetchData));
    } catch (error) {
      emit(SyncedFailed(lastSynced: state.lastSynced));
      _log.info('could not sync $event, retries in ${syncDelay.retryDelay}');
      await Future.delayed(syncDelay.retryDelay);
      if (isClosed) return;
      _log.info('retrying $event');
      add(event);
    }
  }

  Future<bool> _sync(Object event) async {
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

EventTransformer<Event> bufferTimer<Event>(SyncDelays syncDelays) =>
    (events, mapper) => events
        .throttleTime(syncDelays.betweenSync, trailing: true, leading: false)
        .asyncExpand(mapper); // sequential
