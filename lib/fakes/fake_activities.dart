import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

DateTime get _now => DateTime.now().onlyMinutes();

class FakeActivities {
  static List<Activity> get activities => activitiesWhen(_now);
  static List<Activity> activitiesWhen(DateTime when) => [
        FakeActivity.dayAfter(when),
        FakeActivity.longPast(when),
        FakeActivity.past(when),
        FakeActivity.endsAt(when),
        FakeActivity.onTime(when),
        FakeActivity.startsOneMinuteAfter(when),
        FakeActivity.future(when),
        FakeActivity.dayBefore(when),
        FakeActivity.twoDaysFromNow(when),
        FakeActivity.longSpanning(when),
        FakeActivity.fullday(when),
        FakeActivity.yesterdayFullday(when),
        FakeActivity.tomorrowFullday(when),
        FakeActivity.startsAt(when,
            title:
                'long long, long, long long, long, long long, long, long long, long name',
            image: true),
      ];

  static List<Activity> get oneEveryMinute => oneEveryMinuteWhen(_now);
  static List<Activity> oneEveryMinuteWhen(DateTime when, {int minutes = 40}) {
    when = when.subtract(Duration(minutes: minutes ~/ 2));
    return [
      for (int i = 0; i < minutes; i++)
        Activity.createNew(
            title: 'Minute $i',
            startTime: when.add(Duration(minutes: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 1).inMilliseconds,
            category: 0,
            reminderBefore: [],
            fileId: i % 3 == 0 ? 'fileId' : null,
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
            fileId: i % 3 == 0 ? 'fileId' : null,
            alarmType: ALARM_SILENT),
    ];
  }

  static List<Activity> get allPast => allPastWhen(_now);
  static List<Activity> allPastWhen(DateTime when, {int minutes = 10}) {
    when = when.subtract(Duration(minutes: 20));
    return [
      for (int i = 0; i < minutes; i++)
        Activity.createNew(
            title: 'past $i',
            startTime:
                when.subtract(Duration(minutes: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 15).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
    ];
  }
}

class FakeActivity {
  static Activity onTime(
          [DateTime date, Duration duration = const Duration(hours: 1)]) =>
      startsAt(date ?? _now, title: 'now', duration: duration);
  static Activity startsOneMinuteAfter([DateTime date]) =>
      startsAt((date ?? _now).add(Duration(minutes: 1)), title: 'soon start');
  static Activity startsAfter(Duration duration, [DateTime date]) =>
      startsAt((date ?? _now).add(duration), title: 'start in $duration');
  static Activity past([DateTime date]) =>
      endsAt((date ?? _now).subtract(Duration(minutes: 1)), title: 'past');
  static Activity future(
          [DateTime date, Duration inDuration = const Duration(hours: 1)]) =>
      startsAt((date ?? _now).add(inDuration), title: 'future');
  static Activity dayAfter([DateTime date]) =>
      startsAt((date ?? _now).add(Duration(days: 1)), title: 'tomorrow');
  static Activity longPast([DateTime date]) =>
      startsAt((date ?? _now).subtract(Duration(hours: 2)), title: 'long past');
  static Activity dayBefore([DateTime date]) =>
      startsAt((date ?? _now).subtract(Duration(days: 1)), title: 'yesterday');
  static Activity twoDaysFromNow([DateTime date]) =>
      startsAt((date ?? _now).add(Duration(days: 2)),
          title: 'two days from now');

  static Activity startsAt(DateTime when,
          {String title,
          bool image = false,
          Duration duration = const Duration(hours: 1)}) =>
      Activity.createNew(
          title: title ?? '$when',
          startTime: when.millisecondsSinceEpoch,
          duration: duration.inMilliseconds,
          category: 0,
          reminderBefore: [],
          fileId: image ? 'image' : null,
          alarmType: ALARM_SILENT);

  static Activity endsAt(DateTime when,
          {String title,
          bool image = false,
          Duration duration = const Duration(hours: 1)}) =>
      Activity.createNew(
          title: title ?? 'ends at $when',
          startTime: when.subtract(duration).millisecondsSinceEpoch,
          duration: duration.inMilliseconds,
          category: 0,
          reminderBefore: [],
          fileId: image ? 'image' : null,
          alarmType: ALARM_SILENT);
  static Activity longSpanning(DateTime when,
          [String title = 'most of day', bool image = false]) =>
      startsAt(DateTime(when.year, when.month, when.day),
          title: title, image: image, duration: Duration(hours: 16));

  static Activity reocurrsWeekends([DateTime startDate]) =>
      reoccurs(startDate, RecurrentType.weekly, allWeekends,
          title: 'recurs weekend');
  static Activity reocurrsMondays([DateTime startDate]) => reoccurs(
      startDate, RecurrentType.weekly, Recurs.EVEN_MONDAY | Recurs.ODD_MONDAY,
      title: 'recurs monday');
  static Activity reocurrsTuedays([DateTime startDate]) => reoccurs(
      startDate, RecurrentType.weekly, Recurs.EVEN_TUESDAY | Recurs.ODD_TUESDAY,
      title: 'recurs tuesday');
  static Activity reocurrsWednesdays([DateTime startDate]) => reoccurs(
      startDate,
      RecurrentType.weekly,
      Recurs.EVEN_WEDNESDAY | Recurs.ODD_WEDNESDAY,
      title: 'recurs wednesday');
  static Activity reocurrsThursdays([DateTime startDate]) => reoccurs(startDate,
      RecurrentType.weekly, Recurs.EVEN_THURSDAY | Recurs.ODD_THURSDAY,
      title: 'recurs thursday');
  static Activity reocurrsFridays([DateTime startDate]) => reoccurs(
      startDate, RecurrentType.weekly, Recurs.EVEN_FRIDAY | Recurs.ODD_FRIDAY,
      title: 'recurs friday');
  static Activity reocurrsSaturdays([DateTime startDate]) => reoccurs(startDate,
      RecurrentType.weekly, Recurs.EVEN_SATURDAY | Recurs.ODD_SATURDAY,
      title: 'recurs saturday');
  static Activity reocurrsSunday([DateTime startDate]) => reoccurs(
      startDate, RecurrentType.weekly, Recurs.EVEN_SUNDAY | Recurs.ODD_SUNDAY,
      title: 'recurs sunday');
  static Activity reocurrsOnDay(int day,
          [DateTime startDate, DateTime endDate]) =>
      reoccurs(startDate, RecurrentType.monthly, Recurs.onDayOfMonth(day),
          endTime: endDate, title: 'recurs on month day $day');
  static Activity reocurrsOnDate(DateTime day,
          [DateTime startTime, DateTime endTime]) =>
      reoccurs(
          startTime ?? day, RecurrentType.yearly, Recurs.dayOfYearData(day),
          endTime: endTime, title: 'recurs on date $day');
  static Activity reoccurs(
    DateTime startTime,
    RecurrentType recurrentType,
    int recurrrentData, {
    DateTime endTime,
    String title,
  }) =>
      Activity.createNew(
          title: title ?? 'reocurrs $recurrentType $recurrrentData',
          startTime: (startTime ?? _now.subtract(Duration(days: 366)))
              .millisecondsSinceEpoch,
          endTime: endTime?.millisecondsSinceEpoch ?? Recurs.NO_END,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          recurrentType: recurrentType.index,
          recurrentData: recurrrentData,
          reminderBefore: [],
          alarmType: ALARM_SILENT);

  static Activity fullday([DateTime date]) => fulldayWhen(date ?? _now);
  static Activity yesterdayFullday([DateTime date]) =>
      fulldayWhen((date ?? _now).subtract(Duration(days: 1)), 'yesterday');
  static Activity tomorrowFullday([DateTime date]) =>
      fulldayWhen((date ?? _now).add(Duration(days: 1)))
          .copyWith(title: 'tomorrow');
  static Activity fulldayWhen(DateTime when,
          [String title = 'most of day', bool image = false]) =>
      Activity.createNew(
          title: '${title != null ? title : ''} fullday',
          startTime:
              DateTime(when.year, when.month, when.day).millisecondsSinceEpoch,
          endTime: DateTime(when.year, when.month, when.day + 1)
                  .millisecondsSinceEpoch -
              1,
          duration: Duration(days: 1).inMilliseconds - 1,
          category: 0,
          fullDay: true,
          reminderBefore: [60 * 60 * 1000],
          fileId: image ? 'image' : null,
          alarmType: NO_ALARM);
}

const int oddWeekdays = Recurs.ODD_MONDAY |
    Recurs.ODD_TUESDAY |
    Recurs.ODD_WEDNESDAY |
    Recurs.ODD_THURSDAY |
    Recurs.ODD_FRIDAY;
const int evenWeekdays = Recurs.EVEN_MONDAY |
    Recurs.EVEN_TUESDAY |
    Recurs.EVEN_WEDNESDAY |
    Recurs.EVEN_THURSDAY |
    Recurs.EVEN_FRIDAY;
const int allWeekdays = oddWeekdays | evenWeekdays;
const int oddWeekends = Recurs.ODD_SATURDAY | Recurs.ODD_SUNDAY;
const int evenWeekends = Recurs.EVEN_SATURDAY | Recurs.EVEN_SUNDAY;
const int allWeekends = evenWeekends | oddWeekends;
const int allWeek = allWeekdays | allWeekends;
