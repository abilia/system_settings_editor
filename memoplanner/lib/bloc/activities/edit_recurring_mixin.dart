import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityMappingResult {
  ActivityMappingResult(this.save, this.state);
  final Iterable<Activity> save, state;
}

mixin EditRecurringMixin {
  ActivityMappingResult deleteThisDayAndForwardToState({
    required Activity activity,
    required Set<Activity> activities,
    required DateTime day,
  }) {
    final series =
        activities.where((a) => a.seriesId == activity.seriesId).toSet();
    final startsOnOrAfter = series
        .where(
            (a) => a.startTime.isDayAfter(day) || a.startTime.isAtSameDay(day))
        .toSet(); // Should be deleted
    final startBeforeEndsNotBefore = series
        .where((a) => a.startTime.isDayBefore(day))
        .where((a) => !a.recurs.end.isDayBefore(day))
        .toSet(); // Should change endDate
    final deleted = startsOnOrAfter.map((a) => a.copyWith(deleted: true));
    final newEndTime = startBeforeEndsNotBefore
        .map((a) => a.copyWithRecurringEnd(day.millisecondBefore()));

    final shouldSave = deleted.followedBy(newEndTime);
    final allShouldChanged = startsOnOrAfter.union(startBeforeEndsNotBefore);
    final newActivityState =
        activities.difference(allShouldChanged).followedBy(newEndTime);
    return ActivityMappingResult(shouldSave, newActivityState);
  }

  ActivityMappingResult deleteOnlyThisDay({
    required Activity activity,
    required Set<Activity> activities,
    required DateTime day,
  }) {
    final isFirstDay = activity.startTime.isAtSameDay(day);
    final isLastDay = activity.recurs.end.isAtSameDay(day);
    if (isFirstDay && isLastDay && activities.remove(activity)) {
      final save = [activity.copyWith(deleted: true)];
      return ActivityMappingResult(save, activities);
    } else if (isFirstDay) {
      final newActivityStartTime = activity.copyWith(
          startTime: day.nextDay().copyWith(
              hour: activity.startTime.hour,
              minute: activity.startTime.minute));
      return _updateActivityToResult(newActivityStartTime, activities);
    } else if (isLastDay) {
      final newEndTime = activity.copyWithRecurringEnd(day.millisecondBefore());
      return _updateActivityToResult(newEndTime, activities);
    } else {
      final newEndTime = activity.copyWithRecurringEnd(day.millisecondBefore());
      final newActivityStartTime = activity.copyWith(
          newId: true,
          startTime: day.nextDay().copyWith(
              hour: activity.startTime.hour,
              minute: activity.startTime.minute));
      return _updateActivityToResult(newEndTime, activities,
          andAdd: [newActivityStartTime]);
    }
  }

  ActivityMappingResult updateThisDayAndForward({
    required Activity activity,
    required Set<Activity> activities,
    required DateTime day,
  }) {
    final newStart = activity.startTime;
    final series = activities.where((a) => a.seriesId == activity.seriesId);

    final overlappingInSeries = series
        .where((a) => a.isRecurring)
        .where((a) => a.startTime.isDayBefore(newStart))
        .where((a) =>
            a.recurs.end.isDayAfter(newStart) ||
            a.recurs.end.isAtSameDay(newStart))
        .toSet(); // Should be split

    final activityBeforeSplit = overlappingInSeries
        .map((a) => a.copyWithRecurringEnd(
              a.recurs.yearly
                  ? day.onlyDays().millisecondBefore()
                  : newStart.onlyDays().millisecondBefore(),
              newId: true,
            ))
        .toSet();

    final activityAfterDateSplit =
        overlappingInSeries.map((a) => a.copyWith(startTime: newStart));

    final startDayIsOnOrAfter = series
        .where((a) => !a.startTime.isDayBefore(newStart))
        .toSet(); // Should be edited

    final editedAccordingToActivity = startDayIsOnOrAfter
        .followedBy(activityAfterDateSplit)
        .map((a) => a.copyActivity(activity))
        .toSet();

    final allNewEdited = activityBeforeSplit.union(editedAccordingToActivity);
    final oldUnedited = overlappingInSeries.union(startDayIsOnOrAfter);

    return ActivityMappingResult(
      allNewEdited,
      activities.difference(oldUnedited).union(allNewEdited),
    );
  }

  ActivityMappingResult updateOnlyThisDay({
    required ActivityDay activityDay,
    required Set<Activity> activities,
    bool startTimeFromActivityDay = false,
  }) {
    final activity = activityDay.activity;
    final day = activityDay.day;
    final startTime = startTimeFromActivityDay
        ? day.copyWith(
            hour: activity.startTime.hour, minute: activity.startTime.minute)
        : activity.startTime;
    final onlyDayActivity =
        activity.copyWith(recurs: Recurs.not, startTime: startTime);
    final oldActivity = activities.firstWhere((a) => a.id == activity.id);

    final atFirstDay = oldActivity.startTime.isAtSameDay(day);
    final atLastDay = oldActivity.recurs.end.isAtSameDay(day);

    final newActivities = <Activity>[
      if (atFirstDay && !atLastDay)
        oldActivity.copyWith(
          newId: true,
          startTime: oldActivity.startTime.nextDay(),
        )
      else if (atLastDay && !atFirstDay)
        oldActivity.copyWithRecurringEnd(
          day.millisecondBefore(),
          newId: true,
        )
      else if (!atFirstDay && !atLastDay) ...[
        oldActivity.copyWithRecurringEnd(
          day.millisecondBefore(),
          newId: true,
        ),
        oldActivity.copyWith(
          newId: true,
          startTime: day.nextDay().copyWith(
              hour: oldActivity.startTime.hour,
              minute: oldActivity.startTime.minute),
        ),
      ],
    ];

    return _updateActivityToResult(onlyDayActivity, activities,
        andAdd: newActivities);
  }

  ActivityMappingResult _updateActivityToResult(
      Activity activity, Iterable<Activity> activities,
      {Iterable<Activity> andAdd = const []}) {
    final save = [activity, ...andAdd];
    final updatedActivities = activities.map<Activity>((a) {
      return a.id == activity.id ? activity : a;
    }).toList(growable: false);
    return ActivityMappingResult(save, [...updatedActivities, ...andAdd]);
  }
}
