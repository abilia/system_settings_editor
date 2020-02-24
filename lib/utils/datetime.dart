import 'package:meta/meta.dart';

extension DateTimeExtensions on DateTime {
  DateTime onlyDays() => DateTime(year, month, day);

  DateTime onlyMinutes() => DateTime(year, month, day, hour, minute);

  DateTime nextHalfHour() => DateTime(
      year, month, day, minute >= 30 ? hour + 1 : hour, minute >= 30 ? 0 : 30);

  bool isAtSameDay(DateTime otherDate) =>
      onlyDays().isAtSameMomentAs(otherDate.onlyDays());

  bool isDayBefore(DateTime otherDate) =>
      onlyDays().isBefore(otherDate.onlyDays());

  bool onOrBetween(
          {@required DateTime startDate, @required DateTime endDate}) =>
      (isAfter(startDate) && isBefore(endDate)) ||
      isAtSameMomentAs(startDate) ||
      isAtSameMomentAs(endDate);

  // ISO 8601 states:
  // - Week 1 is the week with the first thursday of that year.
  // - 4 of january is always in week 1
  int getWeekNumber() {
    final day = onlyDays();
    var january4th = DateTime(day.year, 1, 4);
    if (january4th.isAfter(day)) {
      january4th = DateTime(day.year - 1, 1, 4);
    }
    final sundayWeek1 = january4th.subtract(Duration(days: january4th.weekday));
    final mondayWeekx = day.subtract(Duration(days: day.weekday - 1));
    final diff = mondayWeekx.difference(sundayWeek1).inDays;
    final week = (diff ~/ 7) + 1;
    final thursdayWeekx = mondayWeekx.add(Duration(days: 3));
    if (week == 53 && thursdayWeekx.month == 1) return 1;
    return week;
  }
}
