import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import 'edit_recurring_mixin.dart';

part 'activities_event.dart';
part 'activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState>
    with EditRecurringMixin {
  final ActivityRepository activityRepository;
  StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  ActivitiesBloc({
    @required this.activityRepository,
    @required this.syncBloc,
    @required PushBloc pushBloc,
  }) : super(ActivitiesNotLoaded()) {
    pushSubscription = pushBloc.listen((state) {
      if (state is PushReceived) {
        add(LoadActivities());
      }
    });
  }

  @override
  Stream<ActivitiesState> mapEventToState(ActivitiesEvent event) async* {
    if (event is LoadActivities) {
      yield* _mapLoadActivitiesToState();
    } else if (event is ManipulateActivitiesEvent) {
      final oldState = state;
      if (oldState is ActivitiesLoaded) {
        final activities = oldState.activities;
        if (event is AddActivity) {
          yield* _mapAddActivityToState(event, activities);
        } else if (event is UpdateActivity) {
          yield* _mapUpdateActivityToState(event, activities);
        } else if (event is DeleteActivity) {
          yield* _mapDeleteActivityToState(event, activities.toSet());
        } else if (event is UpdateRecurringActivity) {
          yield* _mapUpdateRecurringToState(event, activities.toSet());
        } else if (event is DeleteRecurringActivity) {
          yield* _mapDeleteRecurringToState(event, activities.toSet());
        }
      }
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
    AddActivity event,
    Iterable<Activity> activities,
  ) async* {
    yield ActivitiesLoaded(activities.followedBy([event.activity]));
    await _saveActivities([event.activity]);
  }

  Stream<ActivitiesState> _mapDeleteActivityToState(
      DeleteActivity event, Set<Activity> activities) async* {
    if (activities.remove(event.activity)) {
      yield ActivitiesLoaded(activities);
      await _saveActivities([event.activity.copyWith(deleted: true)]);
    }
  }

  Stream<ActivitiesState> _mapUpdateActivityToState(
      UpdateActivity event, Iterable<Activity> activities) async* {
    final activity = event.activity;
    final updatedActivities = activities.map<Activity>((a) {
      return a.id == activity.id ? activity : a;
    }).toList(growable: false);
    yield ActivitiesLoaded(updatedActivities);
    await _saveActivities([activity]);
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
        yield ActivitiesLoaded(activities.difference(series));
        await _saveActivities(series.map((a) => a.copyWith(deleted: true)));
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
    UpdateRecurringActivity event,
    Set<Activity> activities,
  ) async* {
    final activity = event.activity;
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
            day: event.day,
          ),
        );
        break;
      default:
    }
  }

  Stream<ActivitiesState> _handleResult(ActivityMappingResult res) async* {
    yield ActivitiesLoaded(res.state);
    await _saveActivities(res.save);
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
