import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

extension IterableActivity on Iterable<Activity> {
  Iterable<NotificationAlarm> alarmsOnExactMinute(DateTime time) =>
      _alarmsFor(time,
          startTimeTest: (a) => a.startClock(time).isAtSameMomentAs(time),
          endTimeTest: (a) => a.endClock(time).isAtSameMomentAs(time),
          reminderTest: (rs) => rs.activity
              .startClock(time)
              .subtract(rs.reminder)
              .isAtSameMomentAs(time));

  Iterable<NotificationAlarm> alarmsForRange(DateTime time, DateTime end) =>
      _alarmsFor(time,
          startTimeTest: (a) =>
              a.startClock(time).onOrBetween(startDate: time, endDate: end),
          endTimeTest: (a) =>
              a.endClock(time).onOrBetween(startDate: time, endDate: end),
          reminderTest: (rs) => rs.activity
              .startClock(time)
              .subtract(rs.reminder)
              .onOrBetween(startDate: time, endDate: end));

  Iterable<NotificationAlarm> _alarmsFor(DateTime time,
      {bool Function(Activity) startTimeTest,
      bool Function(Activity) endTimeTest,
      bool Function(NewReminder) reminderTest}) {
    final activitiesThisDay = where((a) => a.shouldShowForDay(time.onlyDays()));
    final activitiesWithAlarm =
        activitiesThisDay.where((a) => a.alarm.shouldAlarm);

    final Iterable<NotificationAlarm> startTimeAlarms = activitiesWithAlarm
        .where(startTimeTest)
        .map((a) => NewAlarm(a, alarmOnStart: true));

    final endTimeAlarms = activitiesWithAlarm
        .where((a) => a.hasEndTime)
        .where((a) => a.alarm.atEnd)
        .where(endTimeTest)
        .map((a) => NewAlarm(a, alarmOnStart: false));

    final reminders = activitiesThisDay.expand((a) => a.reminders
        .map((r) => NewReminder(a, reminder: r))
        .where(reminderTest));

    return startTimeAlarms.followedBy(endTimeAlarms).followedBy(reminders);
  }
}
