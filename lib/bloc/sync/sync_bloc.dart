import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'sync_event.dart';

class SyncState {}

class SyncPerformed extends SyncState {}

class SyncNotPerformed extends SyncState {}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final PushCubit pushCubit;
  final LicenseCubit licenseCubit;

  final ActivityRepository activityRepository;
  final UserFileRepository userFileRepository;
  final SortableRepository sortableRepository;
  final GenericRepository genericRepository;
  final SyncDelays syncDelay;
  final _log = Logger('SyncBloc');

  late StreamSubscription _pushSubscription;

  bool get hasSynced => state is SyncPerformed;

  SyncBloc({
    required this.pushCubit,
    required this.licenseCubit,
    required this.activityRepository,
    required this.userFileRepository,
    required this.sortableRepository,
    required this.genericRepository,
    required this.syncDelay,
  }) : super(SyncNotPerformed()) {
    _pushSubscription = pushCubit.stream.listen((v) => add(const SyncAll()));
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
    if (!await _sync(event)) {
      _log.info('could not sync $event, retries in ${syncDelay.retryDelay}');
      await Future.delayed(syncDelay.retryDelay);
      _log.info('retrying $event');
      add(event);
    }
    if (event is SyncAll) emit(SyncPerformed());
  }

  Future<bool> _sync(SyncEvent event) async {
    switch (event.runtimeType) {
      case SyncAll:
        return _syncAll();
      case ActivitySaved:
        if (licenseCubit.validLicense) return activityRepository.synchronize();
        return true;
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
    return results.fold<bool>(true, (prev, next) => prev && next);
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
