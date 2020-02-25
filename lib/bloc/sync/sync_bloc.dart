import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/backend/all.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final BackendSyncService backendSyncService;

  SyncBloc(this.backendSyncService);

  @override
  SyncState get initialState => SyncInitial();

  @override
  Stream<SyncState> mapEventToState(
    SyncEvent event,
  ) async* {
    if (event is ActivitySaved) {
      yield SyncPending();
      final syncResult = await backendSyncService.runSync();
      if (syncResult) {
        yield SyncDone();
      } else {
        yield SyncFailed();
      }
    }
  }
}
