import 'package:calendar_events/calendar_events.dart';
import 'package:utils/utils.dart';

ActivityDay? findNextAlarm(Iterable<Activity> activities, DateTime now) {
  final noneFullDay = activities.where((a) => !a.fullDay).toList();
  if (noneFullDay.isEmpty) return null;

  final List<ActivityDay> next = [];
  var daysIntoTheFuture = 0;
  for (var day = now.onlyDays();
      next.isEmpty && daysIntoTheFuture < 90;
      day = day.nextDay(), daysIntoTheFuture++) {
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
