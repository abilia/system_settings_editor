import 'package:seagull/models.dart';
import 'package:seagull/utils/datetime_utils.dart';

DateTime get _now => onlyMinutes(DateTime.now());

class FakeActivities {
  static List<Activity> get activities => activitiesWhen(_now);
  static List<Activity> activitiesWhen(DateTime when) => [
        FakeActivity.dayAfter(when),
        FakeActivity.longPast(when),
        FakeActivity.past(when),
        FakeActivity.endsAt(when),
        FakeActivity.onTime(when),
        FakeActivity.startsOneMinuteAfter(when),
        FakeActivity.later(when),
        FakeActivity.dayBefore(when),
        FakeActivity.twoDaysFromNow(when),
        FakeActivity.longSpanning(when),
        FakeActivity.fullday(when),
        FakeActivity.yesterdayFullday(when),
        FakeActivity.tomorrowFullday(when),
        FakeActivity.longNameWhen(when),
      ];

  static List<Activity> get oneEveryMinute => oneEveryMinuteWhen(_now);
  static List<Activity> oneEveryMinuteWhen(DateTime when, {int minutes = 120}) {
    when = when.subtract(Duration(minutes: minutes ~/ 2));
    return [
      for (int i = 0; i < minutes; i++)
        Activity.createNew(
            title: 'Minute $i',
            startTime: when.add(Duration(minutes: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 5).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
    ];
  }

  static List<Activity> get oneFullDayEveryDay => oneFullDayEveryDayWhen(_now);
  static List<Activity> oneFullDayEveryDayWhen(DateTime when, {int days = 6}) {
    when = when.subtract(Duration(minutes: days ~/ 2));
    return [
      for (int i = 0; i < days; i++)
        Activity.createNew(
            title: 'fullDay $i',
            fullDay: true,
            startTime: when.add(Duration(days: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 5).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
    ];
  }

  static List<Activity> get allPast => allPastWhen(_now);
  static List<Activity> allPastWhen(DateTime when, {int hours = 6}) {
    when = when.subtract(Duration(minutes: 20));
    return [
      for (int i = 0; i < hours; i++)
        Activity.createNew(
            title: 'past $i',
            startTime: when.subtract(Duration(hours: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 15).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
    ];
  }
}

class FakeActivity {
  static Activity onTime([DateTime date]) => startsAt(date ?? _now , 'now');
  static Activity startsOneMinuteAfter([DateTime date]) => startsAt((date ?? _now).add(Duration(minutes: 1)), 'soon start');
  // static Activity endsOn([DateTime date]) => endsAt((date ?? _now), 'ends soon');
  static Activity past([DateTime date]) => endsAt((date ?? _now).subtract(Duration(minutes: 1)), 'past');
  static Activity future([DateTime date]) => startsAt((date ?? _now).add(Duration(hours: 1)), 'future');
  static Activity dayAfter([DateTime date]) => startsAt((date ?? _now).add(Duration(days: 1)), 'tomorrow');
  static Activity longPast([DateTime date]) => startsAt((date ?? _now).subtract(Duration(hours: 2)), 'long past');
  static Activity later([DateTime date]) => startsAt((date ?? _now).add(Duration(hours: 1)), 'later');
  static Activity dayBefore([DateTime date]) => startsAt((date ?? _now).subtract(Duration(days: 1)), 'yesterday');
  static Activity twoDaysFromNow([DateTime date]) => startsAt((date ?? _now).add(Duration(days: 2)),'two days from now');

  static Activity startsAt(DateTime when, [String title]) => Activity.createNew(
      title: title ?? '$when',
      startTime: when.millisecondsSinceEpoch,
      duration: Duration(hours: 1).inMilliseconds,
      category: 0,
      reminderBefore: [],
      alarmType: ALARM_SILENT);

  static Activity endsAt(DateTime when, [String title]) => Activity.createNew(
      title: title ?? 'ends at $when',
      startTime: when.subtract(Duration(hours: 1)).millisecondsSinceEpoch,
      duration: Duration(hours: 1).inMilliseconds,
      category: 0,
      reminderBefore: [],
      alarmType: ALARM_SILENT);

  static Activity longSpanning(DateTime when) => Activity.createNew(
      title: 'most of day',
      startTime: DateTime(when.year, when.month, when.day).millisecondsSinceEpoch,
      duration: Duration(hours: 16).inMilliseconds,
      category: 0,
      reminderBefore: [0, 1, 2],
      alarmType: ALARM_SILENT);


  static Activity fullday([DateTime date]) => fulldayWhen(date ?? _now);
  static Activity yesterdayFullday([DateTime date]) => fulldayWhen((date ?? _now).subtract(Duration(days: 1)), 'yesterday');
  static Activity tomorrowFullday([DateTime date]) => fulldayWhen((date ?? _now).add(Duration(days: 1))).copyWith(title: 'tomorrow');
  static Activity fulldayWhen(DateTime when, [String title]) => Activity.createNew(
      title: '$title fullday',
      startTime: when.subtract(Duration(hours: 2)).millisecondsSinceEpoch,
      duration: Duration(hours: 1).inMilliseconds,
      category: 0,
      fullDay: true,
      reminderBefore: [60 * 60 * 1000],
      alarmType: ALARM_SILENT);

  static Activity get longName => longNameWhen(_now);
  static Activity longNameWhen(DateTime when) => Activity.createNew(
      title:
          'long10 long9 long8 long7 long6 long5 long4 long3 long2 long1 long0 long-1 long-2 long-3 long-4 long-5 long-6 long-7 long-8 long-9 past',
      startTime: when.subtract(Duration(hours: 2)).millisecondsSinceEpoch,
      duration: Duration(hours: 1).inMilliseconds,
      category: 0,
      infoItem: '{some:info,in:json}',
      reminderBefore: [60 * 60 * 1000],
      alarmType: ALARM_SILENT);
}
