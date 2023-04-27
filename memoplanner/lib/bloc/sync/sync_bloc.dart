import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:repository_base/bloc/sync/sync_event.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sortables/bloc/sync/sortable_sync_event.dart';
import 'package:sortables/repository/data_repository/sortable_repository.dart';
import 'package:utils/bloc/sync/sync_state.dart';

part 'sync_event.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
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
    on<ActivitySaved>(_trySync, transformer: bufferTimer(syncDelay));
    on<FileSaved>(_trySync, transformer: bufferTimer(syncDelay));
    on<SortableSaved>(_trySync, transformer: bufferTimer(syncDelay));
    on<GenericSaved>(_trySync, transformer: bufferTimer(syncDelay));
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

  Future<bool> _sync(SyncEvent event) async {
    switch (event.runtimeType) {
      case SyncAll:
        return _syncAll();
      case ActivitySaved:
        if (licenseCubit.validLicense) return activityRepository.synchronize();
        return false;
      case FileSaved:
        return userFileRepository.synchronize();
      case SortableSaved:
        return sortableRepository.synchronize();
      case GenericSaved:
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
