import 'dart:async';

import 'package:memoplanner/db/all.dart';
import 'package:rxdart/rxdart.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';

import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

part 'sync_event.dart';
part 'sync_state.dart';

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

  bool get isSynced => state is Synced;

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

  Future _trySync(
    SyncEvent event,
    Emitter emit,
  ) async {
    try {
      final didFetchData = await _sync(event);
      if (event is SyncAll) {
        if (didFetchData || !isSynced) {
          final now = clockBloc.state;
          lastSyncDb.setSyncTime(now);
          emit(Synced(lastSynced: now));
        }
      }
    } catch (error) {
      emit(SyncedFailed(lastSynced: state.lastSynced));
      _log.info('could not sync $event, retries in ${syncDelay.retryDelay}');
      await Future.delayed(syncDelay.retryDelay);
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
