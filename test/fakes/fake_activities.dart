import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class FakeActivity {
  static Activity starts(
    DateTime when, {
    String title = 'starts at',
    Duration duration = const Duration(hours: 1),
  }) =>
      Activity.createNew(
          title: title,
          startTime: when,
          duration: duration,
          alarmType: alarmSilent);

  static Activity ends(
    DateTime when, {
    String title = 'ends at',
    Duration duration = const Duration(hours: 1),
  }) =>
      Activity.createNew(
          title: title,
          startTime: when.subtract(duration),
          duration: duration,
          alarmType: alarmSilent);

  static Activity reocurrsEveryDay([DateTime? startDate]) =>
      _reoccurs(startDate, Recurs.weeklyOnDays(List.generate(7, (d) => d + 1)),
          title: 'recurs everyday');
  static Activity reocurrsWeekends([DateTime? startDate]) => _reoccurs(
      startDate,
      Recurs.weeklyOnDays(const [DateTime.saturday, DateTime.sunday]),
      title: 'recurs weekend');
  static Activity reocurrsMondays([DateTime? startDate]) =>
      _reoccurs(startDate, Recurs.weeklyOnDay(DateTime.monday),
          title: 'recurs monday');
  static Activity reocurrsTuedays([DateTime? startDate]) =>
      _reoccurs(startDate, Recurs.weeklyOnDay(DateTime.tuesday),
          title: 'recurs tuesday');
  static Activity reocurrsWednesdays([DateTime? startDate]) =>
      _reoccurs(startDate, Recurs.weeklyOnDay(DateTime.wednesday),
          title: 'recurs wednesday');
  static Activity reocurrsThursdays([DateTime? startDate]) =>
      _reoccurs(startDate, Recurs.weeklyOnDay(DateTime.thursday),
          title: 'recurs thursday');
  static Activity reocurrsFridays([DateTime? startDate]) =>
      _reoccurs(startDate, Recurs.weeklyOnDay(DateTime.friday),
          title: 'recurs friday');

  static Activity reocurrsOnDay(int day,
          [DateTime? startDate, DateTime? endDate]) =>
      _reoccurs(startDate, Recurs.monthly(day, ends: endDate),
          title: 'recurs on month day $day');

  static Activity reocurrsOnDate(DateTime day,
          [DateTime? startTime, DateTime? endTime]) =>
      _reoccurs(startTime ?? day, Recurs.yearly(day, ends: endTime),
          title: 'recurs on date $day');

  static List<Activity> singleInstance(DateTime startDate) {
    final activity = starts(startDate);
    final activity2 = activity.copyWith(
        newId: true,
        title: 'activity2',
        startTime: startDate.add(const Duration(days: 31)));
    return {activity, activity2}.toList();
  }

  static Activity _reoccurs(
    DateTime? startTime,
    Recurs recurs, {
    required String title,
  }) =>
      Activity.createNew(
          title: title,
          startTime: (startTime ?? DateTime(1970, 01, 01)),
          duration: const Duration(hours: 1),
          recurs: recurs,
          alarmType: alarmSilent);

  static Activity fullday(DateTime when, [String title = 'fullday']) =>
      Activity.createNew(
          title: title,
          startTime: when.onlyDays(),
          duration: 1.days() - 1.milliseconds(),
          fullDay: true,
          reminderBefore: const [60 * 60 * 1000],
          alarmType: noAlarm);
}
