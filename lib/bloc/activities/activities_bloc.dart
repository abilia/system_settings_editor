import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/bloc/push/push_bloc.dart';
import 'package:seagull/bloc/push/push_state.dart';
import 'package:seagull/models.dart';
import 'package:seagull/repositories.dart';

import 'bloc.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final ActivityRepository activitiesRepository;
  StreamSubscription pushSubscription;

  ActivitiesBloc({
    @required this.activitiesRepository,
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
      yield* _mapAddActivityToState(event);
    } else if (event is UpdateActivity) {
      yield* _mapUpdateActivityToState(event);
    }
  }

  Stream<ActivitiesState> _mapLoadActivitiesToState() async* {
    try {
      yield ActivitiesLoading();
      final activities = await activitiesRepository.loadActivities();
      yield ActivitiesLoaded(activities);
    } catch (_) {
      yield ActivitiesLoadedFailed();
    }
  }

  Stream<ActivitiesState> _mapAddActivityToState(AddActivity event) async* {
    if (state is ActivitiesLoaded) {
      yield ActivitiesLoaded(
          (state as ActivitiesLoaded).activities.followedBy([event.activity]));
      _saveActivities([event.activity]);
    }
  }

  Stream<ActivitiesState> _mapUpdateActivityToState(
      UpdateActivity event) async* {
    if (state is ActivitiesLoaded) {
      final updatedActivities =
          (state as ActivitiesLoaded).activities.map((activity) {
        return activity.id == event.updatedActivity.id
            ? event.updatedActivity
            : activity;
      });
      yield ActivitiesLoaded(updatedActivities);
      _saveActivities([event.updatedActivity]);
    }
  }

  Future _saveActivities(Iterable<Activity> activities) =>
      activitiesRepository.saveActivities(activities);

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
