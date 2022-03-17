import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

const maxNotifications = 50;

const List<Duration> unsignedOffActivityReminders = [
  Duration(minutes: 15),
  Duration(minutes: 30),
  Duration(minutes: 45),
  Duration(hours: 1),
  Duration(hours: 1, minutes: 15),
  Duration(hours: 1, minutes: 30),
  Duration(hours: 1, minutes: 45),
  Duration(hours: 2),
];

Iterable<ReminderUnchecked> uncheckedReminders(ActivityDay activityDay) =>
    unsignedOffActivityReminders
        .map((r) => ReminderUnchecked(activityDay, reminder: r));

extension IterableActivity on Iterable<Activity> {
  List<ActivityAlarm> alarmsOnExactMinute(DateTime time) => _alarmsFor(time,
      startTimeTest: (a) => a.start.isAtSameMomentAs(time),
      endTimeTest: (a) => a.end.isAtSameMomentAs(time),
      reminderTest: (rs) => rs.notificationTime.isAtSameMomentAs(time));

  List<ActivityAlarm> _alarmsFor(
    DateTime time, {
    required bool Function(ActivityDay) startTimeTest,
    required bool Function(ActivityDay) endTimeTest,
    required bool Function(ActivityAlarm) reminderTest,
  }) {
    final day = time.onlyDays();
    final activitiesThisDay = where((a) => !a.fullDay)
        .expand((a) => a.dayActivitiesForDay(day))
        .where((a) => !a.isSignedOff)
        .toList();
    final activitiesWithAlarm =
        activitiesThisDay.where((ad) => ad.activity.alarm.shouldAlarm);

    final startTimeAlarms = activitiesWithAlarm
        .where(startTimeTest)
        .map<ActivityAlarm>((ad) => StartAlarm(ad));

    final endTimeAlarms = activitiesWithAlarm
        .where((a) => a.activity.hasEndTime)
        .where((a) => a.activity.alarm.atEnd)
        .where(endTimeTest)
        .map<ActivityAlarm>(EndAlarm.new);

    final reminders = activitiesThisDay.expand(
      (ad) => [
        ...ad.activity.reminders.map((r) => ReminderBefore(ad, reminder: r)),
        if (!ad.isSignedOff && ad.activity.checkable) ...uncheckedReminders(ad),
      ].where(reminderTest),
    );

    return [...startTimeAlarms, ...endTimeAlarms, ...reminders];
  }

  Iterable<ActivityAlarm> alarmsFrom(
    DateTime time, {
    int take = maxNotifications,
    int maxDays = 60,
  }) {
    final nextDay = time.nextDay().onlyDays();
    final endTime = nextDay.subtract(1.minutes());
    final alarmsToday = _alarmsForRestOfDay(time, endTime);
    final alarmsTomorrowAndForward = _alarmsForDay(
      nextDay,
      notBefore: time,
      take: take - alarmsToday.length,
      depth: maxDays,
    );
    return _sortAndTake([...alarmsToday, ...alarmsTomorrowAndForward], take);
  }

  List<ActivityAlarm> _alarmsForRestOfDay(DateTime start, DateTime end) =>
      _alarmsFor(start,
          startTimeTest: (a) =>
              a.start.inInclusiveRange(startDate: start, endDate: end),
          endTimeTest: (a) =>
              a.start.isAtSameDay(start) && a.end.isAtSameMomentOrAfter(start),
          reminderTest: (rs) =>
              rs.notificationTime.isAtSameMomentOrAfter(start));

  Iterable<ActivityAlarm> _alarmsForDay(
    DateTime day, {
    required DateTime notBefore,
    required int take,
    required int depth,
  }) {
    if (depth < 0) return <ActivityAlarm>[];

    final alarms = _alarmsFor(
      day,
      startTimeTest: (a) => a.start.isAtSameDay(day),
      endTimeTest: (a) => a.start.isAtSameDay(day),
      reminderTest: (rs) =>
          rs.notificationTime.isAtSameMomentOrAfter(notBefore),
    );
    return [
      ...alarms,
      ..._alarmsForDay(
        day.nextDay(),
        notBefore: notBefore,
        take: take - alarms.length,
        depth: take < 0 ? -1 : --depth,
      )
    ];
  }

  Iterable<ActivityAlarm> _sortAndTake(List<ActivityAlarm> alarms, int take) =>
      (alarms..sort((a, b) => a.notificationTime.compareTo(b.notificationTime)))
          .take(take);
}
