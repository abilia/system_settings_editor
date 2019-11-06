import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models.dart';
import 'package:seagull/repositories.dart';

import 'bloc.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final ActivityRepository activitiesRepository;

  ActivitiesBloc({@required this.activitiesRepository});

  @override
  ActivitiesState get initialState => ActivitiesLoading();

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
      final activities = await this.activitiesRepository.loadActivities();
      yield ActivitiesLoaded(activities);
    } catch (_) {
      yield ActivitiesNotLoaded();
    }
  }

  Stream<ActivitiesState> _mapAddActivityToState(AddActivity event) async* {
    if (state is ActivitiesLoaded) {
      final updatedActivities =
          (state as ActivitiesLoaded).activities.toList()
            ..add(event.activity);
      yield ActivitiesLoaded(updatedActivities);
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
}
