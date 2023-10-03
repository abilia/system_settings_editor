import 'package:calendar_events/calendar_events.dart';
import 'package:utils/utils.dart';

ActivityDay findNextAlarm(Iterable<Activity> activities, DateTime now) {
  final noneFullDay = activities.where((a) => !a.fullDay).toList();
  final List<ActivityDay> next = [];

  for (var day = now.onlyDays(); next.isEmpty; day = day.nextDay()) {
    next.addAll(
      noneFullDay
          .expand(
            (a) => a.dayActivitiesForDay(
              day,
              includeMidnight: true,
            ),
          )
          .where((element) => element.start.isAfter(now)),
    );
  }
  return (next..sort()).first;
}
