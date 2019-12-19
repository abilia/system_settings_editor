import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

extension IterableActivity on Iterable<Activity> {
  Iterable<NotificationAlarm> alarmsFor(DateTime time, {DateTime end}) {
    bool atMinute = end == null;
    final activitiesThisDay = where((a) => a.shouldShowForDay(time.onlyDays()));
    final activitiesWithAlarm =
        activitiesThisDay.where((a) => a.alarm.shouldAlarm);

    final Iterable<NotificationAlarm> startTimeAlarms = activitiesWithAlarm
        .where((a) => atMinute
            ? a.startClock(time).isAtSameMomentAs(time)
            : a.startClock(time).onOrBetween(startDate: time, endDate: end))
        .map((a) => NewAlarm(a, alarmOnStart: true));

    final endTimeAlarms = activitiesWithAlarm
        .where((a) => a.hasEndTime)
        .where((a) => a.alarm.atEnd)
        .where((a) => atMinute
            ? a.endClock(time).isAtSameMomentAs(time)
            : a.startClock(time).onOrBetween(startDate: time, endDate: end))
        .map((a) => NewAlarm(a, alarmOnStart: false));

    final reminders = activitiesThisDay.expand((a) => a.reminders
        .map((r) => NewReminder(a, reminder: r))
        .where((rs) => atMinute
            ? rs.activity
                .startClock(time)
                .subtract(rs.reminder)
                .isAtSameMomentAs(time)
            : rs.activity
                .startClock(time)
                .subtract(rs.reminder)
                .onOrBetween(startDate: time, endDate: end)));

    return startTimeAlarms.followedBy(endTimeAlarms).followedBy(reminders);
  }
}
