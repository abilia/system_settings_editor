import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

mixin EditRecurringMixin {
  Iterable<Activity> deleteThisDayAndForwardToState({
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

    return deleted.followedBy(newEndTime);
  }

  Iterable<Activity> deleteOnlyThisDay({
    required Activity activity,
    required Set<Activity> activities,
    required DateTime day,
  }) {
    final isFirstDay = activity.startTime.isAtSameDay(day);
    final isLastDay = activity.recurs.end.isAtSameDay(day);
    if (isFirstDay && isLastDay && activities.remove(activity)) {
      return [activity.copyWith(deleted: true)];
    } else if (isFirstDay) {
      final newActivityStartTime = activity.copyWith(
          startTime: day.nextDay().copyWith(
              hour: activity.startTime.hour,
              minute: activity.startTime.minute));
      return [newActivityStartTime];
    } else if (isLastDay) {
      final newEndTime = activity.copyWithRecurringEnd(day.millisecondBefore());
      return [newEndTime];
    } else {
      final newEndTime = activity.copyWithRecurringEnd(day.millisecondBefore());
      final newActivityStartTime = activity.copyWith(
          newId: true,
          startTime: day.nextDay().copyWith(
              hour: activity.startTime.hour,
              minute: activity.startTime.minute));
      return [newEndTime, newActivityStartTime];
    }
  }

  Iterable<Activity> updateThisDayAndForward({
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

    return activityBeforeSplit.union(editedAccordingToActivity);
  }

  Iterable<Activity> updateOnlyThisDay({
    required Activity activity,
    required Set<Activity> activities,
    required DateTime day,
  }) {
    final onlyDayActivity = activity.copyWith(recurs: Recurs.not);
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

    return [onlyDayActivity, ...newActivities];
  }
}
