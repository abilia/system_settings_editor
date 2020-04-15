import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import 'bloc.dart';
import 'edit_recurring_mixin.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState>
    with EditRecurringMixin {
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
      if (event is DeleteRecurringActivity) {
        yield* _mapDeleteRecurringToState(event, activities);
      } else if (activities.remove(activity)) {
        await _saveActivities([activity.copyWith(deleted: true)]);
        yield ActivitiesLoaded(activities);
      }
    }
  }

  Stream<ActivitiesState> _mapUpdateActivityToState(
      UpdateActivity event, ActivitiesState oldState) async* {
    if (oldState is ActivitiesLoaded) {
      final activities = oldState.activities;
      if (event is UpdateRecurringActivity) {
        yield* _mapUpdateRecurringToState(activities.toSet(), event);
      } else {
        final activity = event.updatedActivity;
        await _saveActivities([activity]);
        final updatedActivities = activities.map<Activity>((a) {
          return a.id == activity.id ? activity : a;
        }).toList(growable: false);
        yield ActivitiesLoaded(updatedActivities);
      }
    }
  }

  Stream<ActivitiesState> _mapDeleteRecurringToState(
    DeleteRecurringActivity event,
    Set<Activity> activities,
  ) async* {
    final activity = event.activity;
    switch (event.applyTo) {
      case ApplyTo.allDays:
        final series =
            activities.where((a) => a.seriesId == activity.seriesId).toSet();
        await _saveActivities(series.map((a) => a.copyWith(deleted: true)));
        yield ActivitiesLoaded(activities.difference(series));
        break;
      case ApplyTo.thisDayAndForward:
        yield* _handleResult(
          deleteThisDayAndForwardToState(
            activities: activities,
            activity: activity,
            day: event.day,
          ),
        );
        break;
      case ApplyTo.onlyThisDay:
        yield* _handleResult(
          deleteOnlyThisDay(
            activity: activity,
            activities: activities,
            day: event.day,
          ),
        );
        break;
    }
  }

  Stream<ActivitiesState> _mapUpdateRecurringToState(
      Set<Activity> activities, UpdateRecurringActivity event) async* {
    final activity = event.updatedActivity;
    switch (event.applyTo) {
      case ApplyTo.thisDayAndForward:
        yield* _handleResult(
          updateThisDayAndForward(
            activity: activity,
            activities: activities,
          ),
        );
        break;
      case ApplyTo.onlyThisDay:
        yield* _handleResult(
          updateOnlyThisDay(
            activities: activities,
            activity: activity,
            day: event.day.onlyDays(),
          ),
        );
        break;
      default:
    }
  }

  Stream<ActivitiesState> _handleResult(ActivityMappingResult res) async* {
    await _saveActivities(res.save);
    yield ActivitiesLoaded(res.state);
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
