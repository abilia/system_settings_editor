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
      print('got push to activities bloc with state: $state');
      if (state is PushReceived && state.pushType == PushType.calendar) {
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
    } else if (event is DeleteActivity) {
      yield* _mapDeleteActivityToState(event, state);
    }
  }

  Stream<ActivitiesState> _mapLoadActivitiesToState() async* {
    try {
      final activities = await activityRepository.load();
      yield ActivitiesLoaded(activities);
    } catch (_) {
      yield ActivitiesLoadedFailed();
    }
  }

  Stream<ActivitiesState> _mapAddActivityToState(
      AddActivity event, ActivitiesState oldState) async* {
    if (oldState is ActivitiesLoaded) {
      await _saveActivities([event.activity]);
      yield ActivitiesLoaded(oldState.activities.followedBy([event.activity]));
    }
  }

  Stream<ActivitiesState> _mapDeleteActivityToState(
      DeleteActivity event, ActivitiesState oldState) async* {
    if (oldState is ActivitiesLoaded) {
      final activity = event.activity;
      final activities = oldState.activities.toSet();
      if (activities.remove(activity)) {
        await _saveActivities([activity.copyWith(deleted: true)]);
        yield ActivitiesLoaded(activities);
      }
    }
  }

  Stream<ActivitiesState> _mapUpdateActivityToState(
      UpdateActivity event, ActivitiesState oldState) async* {
    if (oldState is ActivitiesLoaded) {
      await _saveActivities([event.updatedActivity]);
      final updatedActivities = oldState.activities.map<Activity>((activity) {
        return activity.id == event.updatedActivity.id
            ? event.updatedActivity
            : activity;
      });
      yield ActivitiesLoaded(updatedActivities);
    }
  }

  Future<void> _saveActivities(Iterable<Activity> activities) async {
    await activityRepository.save(activities);
    syncBloc.add(ActivitySaved());
  }

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
