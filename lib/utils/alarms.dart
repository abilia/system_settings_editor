import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

const List<Duration> unSignedOffActivityReminders = [
  Duration(minutes: 15),
  Duration(minutes: 30),
  Duration(minutes: 45),
  Duration(hours: 1),
  Duration(hours: 1, minutes: 15),
  Duration(hours: 1, minutes: 30),
  Duration(hours: 1, minutes: 45),
  Duration(hours: 2),
];

extension IterableActivity on Iterable<Activity> {
  List<NotificationAlarm> alarmsOnExactMinute(DateTime time) => _alarmsFor(time,
      startTimeTest: (a) => a.start.isAtSameMomentAs(time),
      endTimeTest: (a) => a.end.isAtSameMomentAs(time),
      reminderTest: (rs) => rs.notificationTime.isAtSameMomentAs(time));

  List<NotificationAlarm> _alarmsFor(DateTime time,
      {bool Function(ActivityDay) startTimeTest,
      bool Function(ActivityDay) endTimeTest,
      bool Function(NotificationAlarm) reminderTest}) {
    final day = time.onlyDays();
    final activitiesThisDay = where((a) => !a.fullDay)
        .expand((a) => a.dayActivitiesForDay(day))
        .where((e) => e != null)
        .toList();
    final activitiesWithAlarm =
        activitiesThisDay.where((ad) => ad.activity.alarm.shouldAlarm);

    final startTimeAlarms = activitiesWithAlarm
        .where(startTimeTest)
        .map<NotificationAlarm>((ad) => StartAlarm.from(ad));

    final endTimeAlarms = activitiesWithAlarm
        .where((a) => a.activity.hasEndTime)
        .where((a) => a.activity.alarm.atEnd)
        .where(endTimeTest)
        .map<NotificationAlarm>((a) => EndAlarm(a.activity, a.day));

    final reminders = activitiesThisDay.expand(
      (ad) => [
        ...ad.activity.reminders
            .map((r) => ReminderBefore.from(ad, reminder: r)),
        if (!ad.isSignedOff && ad.activity.checkable)
          ...unSignedOffActivityReminders
              .map((r) => ReminderUnchecked.from(ad, reminder: r)),
      ].where(reminderTest),
    );

    return [...startTimeAlarms, ...endTimeAlarms, ...reminders];
  }

  Iterable<NotificationAlarm> alarmsFrom(
    DateTime time, {
    int take = 50,
    int maxDays = 30,
  }) {
    final nextDay = time.nextDay().onlyDays();
    final endTime = nextDay.subtract(1.minutes());
    final alarmsToday = _alarmsForRestOfDay(time, endTime);
    final alarmsTomorrowAndForward = _alarmsForDay(
      nextDay,
      notBefore: time,
      depth: maxDays,
    );
    return _sortAndTake([...alarmsToday, ...alarmsTomorrowAndF  orward], take);
  }

  List<NotificationAlarm> _alarmsForRestOfDay(DateTime start, DateTime end) =>
      _alarmsFor(start,
          startTimeTest: (a) =>
              a.start.inInclusiveRange(startDate: start, endDate: end),
          endTimeTest: (a) =>
              a.start.isAtSameDay(start) && a.end.isAtSameMomentOrAfter(start),
          reminderTest: (rs) =>
              rs.notificationTime.isAtSameMomentOrAfter(start));

  Iterable<NotificationAlarm> _alarmsForDay(
    DateTime day, {
    @required DateTime notBefore,
    @required int depth,
  }) {
    if (depth < 0) return <NotificationAlarm>[];

    return _alarmsFor(
      day,
      startTimeTest: (a) => a.start.isAtSameDay(day),
      endTimeTest: (a) => a.start.isAtSameDay(day),
      reminderTest: (rs) =>
          rs.notificationTime.isAtSameMomentOrAfter(notBefore),
    ).followedBy(
      _alarmsForDay(
        day.nextDay(),
        notBefore: notBefore,
        depth: --depth,
      ),
    );
  }

  Iterable<NotificationAlarm> _sortAndTake(
          List<NotificationAlarm> alarms, int take) =>
      (alarms..sort((a, b) => a.notificationTime.compareTo(b.notificationTime)))
          .take(take);
}
