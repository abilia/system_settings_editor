import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import 'bloc.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final ActivityRepository activityRepository;
  StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  ActivitiesBloc({
    @required this.activityRepository,
    @required this.syncBloc,
    @required PushBloc pushBloc,
  }) {
    pushSubscription = pushBloc.listen((state) {
      if (state is PushReceived) {
        add(LoadActivities());
      }
    });
  }

  @override
  ActivitiesState get initialState => ActivitiesNotLoaded();

  @override
  Stream<ActivitiesState> mapEventToState(ActivitiesEvent event) async* {
    if (event is LoadActivities) {
      yield* _mapLoadActivitiesToState();
    } else if (event is AddActivity) {
      yield* _mapAddActivityToState(event, state);
    } else if (event is UpdateActivity) {
      yield* _mapUpdateActivityToState(event, state);
    }
  }

  Stream<ActivitiesState> _mapLoadActivitiesToState() async* {
    try {
      final activities = await activityRepository.loadNewActivitiesFromBackend();
      yield ActivitiesLoaded(activities);
    } catch (_) {
      yield ActivitiesLoadedFailed();
    }
  }

  Stream<ActivitiesState> _mapAddActivityToState(
      AddActivity event, ActivitiesState oldState) async* {
    if (oldState is ActivitiesLoaded) {
      final updated = await _saveActivities([event.activity]);
      yield ActivitiesLoaded(oldState.activities.followedBy(updated));
    }
  }

  Stream<ActivitiesState> _mapUpdateActivityToState(
      UpdateActivity event, ActivitiesState oldState) async* {
    if (oldState is ActivitiesLoaded) {
      final successUpdated = await _saveActivities([event.updatedActivity]);
      if (successUpdated.isNotEmpty) {
        final updatedActivities = oldState.activities.map<Activity>((activity) {
          return activity.id == successUpdated.first.id
              ? successUpdated.first
              : activity;
        });
        yield ActivitiesLoaded(updatedActivities);
      }
    }
  }

  Future<Iterable<Activity>> _saveActivities(
      Iterable<Activity> activities) async {
    final savedActivities = await activityRepository.saveActivities(activities);
    syncBloc.add(ActivitySaved());
    return savedActivities;
  }

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
