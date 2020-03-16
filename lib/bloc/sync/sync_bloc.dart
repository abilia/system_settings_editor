import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final ActivityRepository activityRepository;
  final UserFileRepository userFileRepository;

  SyncBloc({
    @required this.activityRepository,
    @required this.userFileRepository,
  });

  @override
  SyncState get initialState => SyncInitial();

  @override
  Stream<SyncState> mapEventToState(
    SyncEvent event,
  ) async* {
    if (event is ActivitySaved) {
      yield* await _mapActivitySavedToState();
    }
    if (event is FileSaved) {
      yield* _mapFileSavedToState();
    }
  }

  Stream<SyncState> _mapActivitySavedToState() async* {
    yield SyncPending();
    final syncResult = await activityRepository.synchronize();
    if (syncResult) {
      yield SyncDone();
    } else {
      yield SyncFailed();
      Future.delayed(1.minutes(), () => add(ActivitySaved()));
    }
  }

  Stream<SyncState> _mapFileSavedToState() async* {
    yield SyncPending();
    final syncResult = await userFileRepository.synchronize();
    if (syncResult) {
      yield SyncDone();
    } else {
      yield SyncFailed();
      Future.delayed(1.minutes(), () => add(FileSaved()));
    }
  }
}
