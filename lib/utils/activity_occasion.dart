import 'package:flutter/material.dart';
import 'package:seagull/bloc/activities/activities_occasion/bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityOccasionUtil {
  static ActivitiesOccasionLoaded mapActivitiesToActivityOccasionsState(
    Iterable<Activity> activities, {
    @required DateTime now,
    @required DateTime day,
  }) {
    final timedActivities = activities
        .where((activity) => activity.shouldShowForDay(day))
        .where((a) => !a.fullDay)
        .map((a) => ActivityOccasion(a, now: now, day: day))
        .toList()
          ..sort((a, b) {
            final occasionComparing =
                a.occasion.index.compareTo(b.occasion.index);
            if (occasionComparing != 0) return occasionComparing;
            final starTimeComparing = a.activity
                .startClock(now)
                .compareTo(b.activity.startClock(now));
            if (starTimeComparing != 0) return starTimeComparing;
            return a.activity.endClock(now).compareTo(b.activity.endClock(now));
          });
    final fullDayActivities = activities
        .where((activity) => activity.shouldShowForDay(day))
        .where((a) => a.fullDay)
        .map((a) => ActivityOccasion.fullDay(a, now: now, day: day))
        .toList();

    final isToday = day.isAtSameDay(now);
    final firstActiveIndex = isToday
        ? _indexOfFirstNoneCompletedOrLastCompletedActivity(timedActivities)
        : -1;

    return ActivitiesOccasionLoaded(
      activities: timedActivities,
      fullDayActivities: fullDayActivities,
      day: day,
      isToday: isToday,
      indexOfCurrentActivity: firstActiveIndex,
    );
  }

  static int _indexOfFirstNoneCompletedOrLastCompletedActivity(
      List<ActivityOccasion> activities) {
    int lastIndex = activities.indexWhere((a) => a.occasion != Occasion.past);
    return lastIndex < 0 ? activities.length - 1 : lastIndex;
  }
}
