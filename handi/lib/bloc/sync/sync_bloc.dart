import 'dart:async';

import 'package:auth/bloc/push/push_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/models/sync_delays.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull_clock/clock_bloc.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final PushCubit pushCubit;
  final ClockBloc clockBloc;

  final SyncDelays syncDelay;

  late StreamSubscription _pushSubscription;

  bool get hasSynced => state is SyncDone;

  SyncBloc({
    required this.pushCubit,
    required this.syncDelay,
    required this.clockBloc,
  }) : super(Syncing(lastSynced: DateTime.now())) {
    _pushSubscription =
        pushCubit.stream.listen((message) => add(const SyncAll()));
    on<SyncAll>(_trySync, transformer: bufferTimer(syncDelay));
  }

  Future<bool> hasDirty() async {
    return false;
  }

  Future _trySync(
    SyncEvent event,
    Emitter emit,
  ) async {
    try {
      emit(Syncing(lastSynced: state.lastSynced));
      final didFetchData = await _sync(event);
      emit(Synced(lastSynced: state.lastSynced, didFetchData: didFetchData));
    } catch (error) {
      emit(SyncedFailed(lastSynced: state.lastSynced));
      await Future.delayed(syncDelay.retryDelay);
      if (isClosed) return;
      add(event);
    }
  }

  Future<bool> _sync(SyncEvent event) async {
    switch (event.runtimeType) {
      case SyncAll:
        return _syncAll();
    }
    throw Exception('Unknown event type $event');
  }

  Future<bool> _syncAll() async {
    final results = await Future.wait([]);
    return results.any((synced) => true);
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
