import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

DateTime get _now => DateTime.now().onlyMinutes();

class FakeActivities {
  static List<Activity> get activities => activitiesWhen(_now);
  static List<Activity> activitiesWhen(DateTime when) => [
        FakeActivity.starts(when.add(1.days())),
        FakeActivity.ends(when.subtract(2.hours())),
        FakeActivity.ends(when.subtract(1.minutes())),
        FakeActivity.ends(when),
        FakeActivity.starts(when),
        FakeActivity.starts(when.add(1.minutes())),
        FakeActivity.starts(when.add(1.hours())),
        FakeActivity.starts(when.subtract(1.days())),
        FakeActivity.starts(when.add(2.days())),
        FakeActivity.fullday(when),
        FakeActivity.fullday(when.subtract(1.days())),
        FakeActivity.fullday(when.add(1.days())),
      ];

  static List<Activity> get oneEveryMinute => oneEveryMinuteWhen(_now);
  static List<Activity> oneEveryMinuteWhen(DateTime when, {int minutes = 40}) {
    when = when.subtract(Duration(minutes: minutes ~/ 2));
    return [
      for (int i = 0; i < minutes; i++)
        Activity.createNew(
            title: 'Minute $i',
            startTime: when.add(Duration(minutes: i)),
            duration: Duration(minutes: 1),
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
            startTime: when.add(Duration(days: i)),
            duration: Duration(minutes: 5),
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
            startTime: when.subtract(Duration(minutes: i)),
            duration: Duration(minutes: 15),
            alarmType: ALARM_SILENT),
    ];
  }
}

class FakeActivity {
  static Activity startsNow([Duration duration = const Duration(hours: 1)]) =>
      starts(_now, title: 'now', duration: duration);

  static Activity startsIn(Duration duration) =>
      starts(_now.add(duration), title: 'start in $duration');

  static Activity starts(
    DateTime when, {
    String title = 'starts at',
    Duration duration = const Duration(hours: 1),
  }) =>
      Activity.createNew(
          title: title,
          startTime: when,
          duration: duration,
          alarmType: ALARM_SILENT);

  static Activity ends(
    DateTime when, {
    String title = 'ends at',
    Duration duration = const Duration(hours: 1),
  }) =>
      Activity.createNew(
          title: title,
          startTime: when.subtract(duration),
          duration: duration,
          alarmType: ALARM_SILENT);

  static Activity reocurrsEveryDay([DateTime startDate]) =>
      reoccurs(startDate, RecurrentType.weekly, allWeek,
          title: 'recurs everyday');
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
          title: title,
          startTime: (startTime ?? _now.subtract(366.days())),
          endTime: endTime ?? Recurs.NO_END,
          duration: Duration(hours: 1),
          recurrentType: recurrentType.index,
          recurrentData: recurrrentData,
          alarmType: ALARM_SILENT);

  static Activity fullday(DateTime when, [String title = 'fullday']) =>
      Activity.createNew(
          title: title,
          startTime: when.onlyDays(),
          duration: 1.days() - 1.milliseconds(),
          fullDay: true,
          reminderBefore: [60 * 60 * 1000],
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
