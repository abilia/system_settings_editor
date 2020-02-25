import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/repository/all.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ActivityRepository activityRepository;

  SyncBloc({
    @required this.activityRepository,
  });

  @override
  SyncState get initialState => SyncInitial();

  @override
  Stream<SyncState> mapEventToState(
    SyncEvent event,
  ) async* {
    if (event is ActivitySaved) {
      yield SyncPending();
      final syncResult = await activityRepository.synchronizeLocalWithBackend();
      if (syncResult) {
        yield SyncDone();
      } else {
        yield SyncFailed();
      }
    }
  }
}
