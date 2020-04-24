import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityMappingResult {
  ActivityMappingResult(this.save, this.state);
  final Iterable<Activity> save, state;
}

mixin EditRecurringMixin {
  ActivityMappingResult deleteThisDayAndForwardToState({
    @required Activity activity,
    @required Set<Activity> activities,
    @required DateTime day,
  }) {
    final series =
        activities.where((a) => a.seriesId == activity.seriesId).toSet();
    final startsOnOrAfter = series
        .where(
            (a) => a.startTime.isDayAfter(day) || a.startTime.isAtSameDay(day))
        .toSet(); // Should be deleted
    final startBeforeEndsNotBefore = series
        .where((a) => a.startTime.isDayBefore(day))
        .where((a) => !a.endTime.isDayBefore(day))
        .toSet(); // Should change endDate
    final deleted = startsOnOrAfter.map((a) => a.copyWith(deleted: true));
    final newEndTime = startBeforeEndsNotBefore
        .map((a) => a.copyWith(endTime: day.millisecondBefore()));

    final shouldSave = deleted.followedBy(newEndTime);
    final allShouldChanged = startsOnOrAfter.union(startBeforeEndsNotBefore);
    final newActivityState =
        activities.difference(allShouldChanged).followedBy(newEndTime);
    return ActivityMappingResult(shouldSave, newActivityState);
  }

  ActivityMappingResult deleteOnlyThisDay({
    @required Activity activity,
    @required Set<Activity> activities,
    @required DateTime day,
  }) {
    final bool isFirstDay = activity.startTime.isAtSameDay(day);
    final bool isLastDay = activity.endTime.isAtSameDay(day);
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
      final newEndTime = activity.copyWith(endTime: day.millisecondBefore());
      return _updateActivityToResult(newEndTime, activities);
    } else {
      final newEndTime = activity.copyWith(endTime: day.millisecondBefore());
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
    @required Activity activity,
    @required Set<Activity> activities,
  }) {
    final newStart = activity.startTime;
    final series = activities.where((a) => a.seriesId == activity.seriesId);

    final overlappingInSeries = series
        .where((a) => a.startTime.isDayBefore(newStart))
        .where((a) =>
            a.endTime.isDayAfter(newStart) || a.endTime.isAtSameDay(newStart))
        .toSet(); // Should be split

    final activityBeforeSplit = overlappingInSeries
        .map((a) => a.copyWith(endTime: newStart.onlyDays().millisecondBefore()))
        .toSet();

    final activityAfterDateSplit = overlappingInSeries
        .map((a) => a.copyWith(newId: true, startTime: newStart));

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
    @required Activity activity,
    @required Set<Activity> activities,
    @required DateTime day,
  }) {
    final onlyDayActivity = activity.copyWith(
      recurrentType: 0,
      recurrentData: 0,
      endTime: activity.startTime.add(activity.duration),
    );

    final oldActivity = activities.firstWhere((a) => a.id == activity.id);

    final bool atFirstDay = oldActivity.startTime.isAtSameDay(day);
    final bool atLastDay = oldActivity.endTime.isAtSameDay(day);

    final newActivities = List<Activity>();
    if (atFirstDay && !atLastDay) {
      newActivities.add(
        oldActivity.copyWith(
          newId: true,
          startTime: oldActivity.startTime.nextDay(),
        ),
      );
    } else if (atLastDay && !atFirstDay) {
      newActivities.add(
        oldActivity.copyWith(
          newId: true,
          endTime: day.millisecondBefore(),
        ),
      );
    } else if (!atFirstDay && !atLastDay) {
      newActivities.addAll(
        [
          oldActivity.copyWith(
            newId: true,
            endTime: day.millisecondBefore(),
          ),
          oldActivity.copyWith(
            newId: true,
            startTime: day.nextDay().copyWith(
                hour: oldActivity.startTime.hour, minute: oldActivity.startTime.minute),
          ),
        ],
      );
    }
    return _updateActivityToResult(onlyDayActivity, activities,
        andAdd: newActivities);
  }

  ActivityMappingResult _updateActivityToResult(
      Activity activity, Iterable<Activity> activities,
      {Iterable<Activity> andAdd = const []}) {
    final save = [activity].followedBy(andAdd);
    final updatedActivities = activities.map<Activity>((a) {
      return a.id == activity.id ? activity : a;
    }).toList(growable: false);
    return ActivityMappingResult(save, updatedActivities.followedBy(andAdd));
  }
}
