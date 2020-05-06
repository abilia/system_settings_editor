import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

extension IterableActivity on Iterable<Activity> {
  List<NotificationAlarm> alarmsOnExactMinute(DateTime time) => _alarmsFor(time,
      startTimeTest: (a) => a.startClock(time).isAtSameMomentAs(time),
      endTimeTest: (a) => a.endClock(time).isAtSameMomentAs(time),
      reminderTest: (rs) => rs.notificationTime.isAtSameMomentAs(time));

  List<NotificationAlarm> _alarmsFor(DateTime time,
      {bool Function(Activity) startTimeTest,
      bool Function(Activity) endTimeTest,
      bool Function(NotificationAlarm) reminderTest}) {
    final day = time.onlyDays();
    final activitiesThisDay =
        where((a) => !a.fullDay).where((a) => a.shouldShowForDay(day)).toList();
    final activitiesWithAlarm =
        activitiesThisDay.where((a) => a.alarm.shouldAlarm).toList();

    final Iterable<NotificationAlarm> startTimeAlarms = activitiesWithAlarm
        .where(startTimeTest)
        .map((a) => NewAlarm(a, day, alarmOnStart: true));

    final endTimeAlarms = activitiesWithAlarm
        .where((a) => a.hasEndTime)
        .where((a) => a.alarm.atEnd)
        .where(endTimeTest)
        .map((a) => NewAlarm(a, day, alarmOnStart: false));

    final reminders = activitiesThisDay.expand((a) => a.reminders
        .map((r) => NewReminder(a, day, reminder: r))
        .where(reminderTest));

    return startTimeAlarms
        .followedBy(endTimeAlarms)
        .followedBy(reminders)
        .toList();
  }

  Iterable<NotificationAlarm> alarmsFrom(
    DateTime time, {
    int take = 50,
    int maxDays = 365,
  }) {
    final nextDay = time.nextDay().onlyDays();
    final endTime = nextDay.subtract(1.minutes());
    final alarms = _alarmsForRestOfDay(time, endTime);
    final int amountOfAlarms = alarms.length;
    if (amountOfAlarms < take) {
      return alarms.followedBy(
        _alarmsForDay(
          nextDay,
          notBefore: time,
          take: take - amountOfAlarms,
          depth: maxDays,
        ),
      );
    }
    return _sortAndTake(alarms, take);
  }

  List<NotificationAlarm> _alarmsForRestOfDay(DateTime start, DateTime end) =>
      _alarmsFor(start,
          startTimeTest: (a) =>
              a.startClock(start).isOnOrBetween(startDate: start, endDate: end),
          endTimeTest: (a) =>
              a.startClock(start).isAtSameDay(start) &&
              a.endClock(start).isAtSameMomentOrAfter(start),
          reminderTest: (rs) =>
              rs.notificationTime.isAtSameMomentOrAfter(start));

  Iterable<NotificationAlarm> _alarmsForDay(DateTime day,
      {@required DateTime notBefore, @required int take, @required int depth}) {
    if (depth < 0) return <NotificationAlarm>[];

    final alarms = _alarmsFor(day,
        startTimeTest: (a) => a.startClock(day).isAtSameDay(day),
        endTimeTest: (a) => a.startClock(day).isAtSameDay(day),
        reminderTest: (rs) =>
            rs.notificationTime.isAtSameMomentOrAfter(notBefore));

    final int amountOfAlarms = alarms.length;
    if (amountOfAlarms < take) {
      return alarms.followedBy(
        _alarmsForDay(
          day.nextDay(),
          notBefore: notBefore,
          take: take - amountOfAlarms,
          depth: --depth,
        ),
      );
    }
    return _sortAndTake(alarms, take);
  }

  Iterable<NotificationAlarm> _sortAndTake(
          List<NotificationAlarm> alarms, int take) =>
      (alarms..sort((a, b) => a.notificationTime.compareTo(a.notificationTime)))
          .take(take);
}
