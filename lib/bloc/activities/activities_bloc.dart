import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sync/bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

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

  Future<void> _saveActivities(Iterable<Activity> activities) async {
    await activityRepository.save(activities);
    syncBloc.add(ActivitySaved());
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
        yield* _updateActivityAndState(event.updatedActivity, activities);
      }
    }
  }

  Stream<ActivitiesState> _mapDeleteRecurringToState(
    DeleteRecurringActivity event,
    Set<Activity> activities,
  ) async* {
    final activity = event.activity;

    final series =
        activities.where((a) => a.seriesId == activity.seriesId).toSet();
    final day = event.day;

    switch (event.applyTo) {
      case ApplyTo.allDays:
        await _saveActivities(series.map((a) => a.copyWith(deleted: true)));
        yield ActivitiesLoaded(activities.difference(series));
        break;

      case ApplyTo.thisDayAndForward:
        final startsOnOrAfter = series
            .where((a) => a.start.isDayAfter(day) || a.start.isAtSameDay(day))
            .toSet(); // Should be deleted
        final startBeforeEndsNotBefore = series
            .where((a) => a.start.isDayBefore(day))
            .where((a) => !a.recurringEnd.isDayBefore(day))
            .toSet(); // Should change endDate
        final deleted = startsOnOrAfter.map((a) => a.copyWith(deleted: true));
        final newEndTime = startBeforeEndsNotBefore
            .map((a) => a.copyWith(endTime: day.millisecondsSinceEpoch - 1));
        await _saveActivities(deleted.followedBy(newEndTime));

        final allShouldChanged =
            startsOnOrAfter.union(startBeforeEndsNotBefore);
        yield ActivitiesLoaded(
            activities.difference(allShouldChanged).followedBy(newEndTime));
        break;

      case ApplyTo.onlyThisDay:
        final bool isFirstDay = activity.start.isAtSameDay(day);
        final bool isLastDay = activity.recurringEnd.isAtSameDay(day);
        if (isFirstDay && isLastDay && activities.remove(activity)) {
          await _saveActivities([activity.copyWith(deleted: true)]);
          yield ActivitiesLoaded(activities);
        } else if (isFirstDay) {
          final newActivityStartTime = activity.copyWith(
              startTime: day
                  .nextDay()
                  .copyWith(
                      hour: activity.start.hour, minute: activity.start.minute)
                  .millisecondsSinceEpoch);
          yield* _updateActivityAndState(newActivityStartTime, activities);
        } else if (isLastDay) {
          final newEndTime =
              activity.copyWith(endTime: day.millisecondsSinceEpoch - 1);
          yield* _updateActivityAndState(newEndTime, activities);
        } else {
          final newEndTime =
              activity.copyWith(endTime: day.millisecondsSinceEpoch - 1);
          final newActivityStartTime = activity.copyWithNewId(
              startTime: day
                  .nextDay()
                  .copyWith(
                      hour: activity.start.hour, minute: activity.start.minute)
                  .millisecondsSinceEpoch);
          yield* _updateActivityAndState(newEndTime, activities,
              andAdd: [newActivityStartTime]);
        }
        break;
    }
  }

  Stream<ActivitiesState> _updateActivityAndState(
      Activity activity, Iterable<Activity> activities,
      {Iterable<Activity> andAdd = const []}) async* {
    await _saveActivities([activity].followedBy(andAdd));
    final updatedActivities = activities.map<Activity>((a) {
      return a.id == activity.id ? activity : a;
    }).toList(growable: false);
    yield ActivitiesLoaded(updatedActivities.followedBy(andAdd));
  }

  Stream<ActivitiesState> _mapUpdateRecurringToState(
      Set<Activity> activities, UpdateRecurringActivity event) async* {
    final activity = event.updatedActivity;

    switch (event.applyTo) {
      case ApplyTo.thisDayAndForward:
        final newStart = activity.start;
        final series = activities.where((a) => a.seriesId == activity.seriesId);

        final overlappingInSeries = series
            .where((a) => a.start.isDayBefore(newStart))
            .where((a) => !a.end.isDayAfter(newStart))
            .toSet(); // Should be split

        final activityBeforeSplit = overlappingInSeries
            .map((a) => a.copyWith(
                endTime: newStart.onlyDays().millisecondsSinceEpoch - 1))
            .toSet();

        final activityAfterDateSplit = overlappingInSeries.map(
            (a) => a.copyWithNewId(startTime: newStart.millisecondsSinceEpoch));

        final startDayIsOnOrAfter = series
            .where((a) => !a.start.isDayBefore(newStart))
            .toSet(); // Should be edited

        final editedAccordingToActivity = startDayIsOnOrAfter
            .followedBy(activityAfterDateSplit)
            .map(
              (a) => a.copyWith(
                title: activity.title,
                startTime: a.start
                    .copyWith(
                      hour: newStart.hour,
                      minute: newStart.minute,
                    )
                    .millisecondsSinceEpoch,
                duration: activity.duration,
                category: activity.category,
                checkable: activity.checkable,
                removeAfter: activity.removeAfter,
                secret: activity.secret,
                fullDay: activity.fullDay,
                reminderBefore: activity.reminderBefore,
                fileId: activity.fileId,
                icon: activity.icon,
                alarmType: activity.alarmType,
                infoItem: activity.infoItem,
              ),
            )
            .toSet();

        final allNewEdited =
            activityBeforeSplit.union(editedAccordingToActivity);
        final oldUnedited = overlappingInSeries.union(startDayIsOnOrAfter);

        await _saveActivities(allNewEdited);
        yield ActivitiesLoaded(
            activities.difference(oldUnedited).union(allNewEdited));
        break;

      case ApplyTo.onlyThisDay:
        final day = event.day.onlyDays();
        final onlyDayActivity = activity.copyWith(
            recurrentType: 0,
            recurrentData: 0,
            endTime: activity.startTime + activity.duration);
        final newId = onlyDayActivity.copyWithNewId();

        final oldActivity = activities.firstWhere((a) => a.id == activity.id);

        final bool atFirstDay = oldActivity.start.isAtSameDay(day);
        final bool atLastDay = oldActivity.recurringEnd.isAtSameDay(day);

        if (atFirstDay && atLastDay) {
          yield* _updateActivityAndState(onlyDayActivity, activities);
        } else if (atFirstDay) {
          final updatedOldActivity = oldActivity.copyWith(
              startTime: oldActivity.start.nextDay().millisecondsSinceEpoch);
          yield* _updateActivityAndState(updatedOldActivity, activities,
              andAdd: [newId]);
        } else if (atLastDay) {
          final updatedOldActivity = oldActivity.copyWith(
              endTime: event.day.millisecondsSinceEpoch - 1);
          yield* _updateActivityAndState(updatedOldActivity, activities,
              andAdd: [newId]);
        } else {
          final seriesBeforeModified =
              oldActivity.copyWith(endTime: day.millisecondsSinceEpoch - 1);
          final seriesAfterModified = oldActivity.copyWithNewId(
              startTime: day
                  .nextDay()
                  .copyWith(
                      hour: oldActivity.start.hour,
                      minute: oldActivity.start.minute)
                  .millisecondsSinceEpoch);
          yield* _updateActivityAndState(seriesBeforeModified, activities,
              andAdd: [seriesAfterModified, newId]);
        }
        break;
      default:
    }
  }

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
