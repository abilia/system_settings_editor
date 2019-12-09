//TODO(bornold) make these extensions methods when flutter goes dart 3.6

import 'package:meta/meta.dart';

DateTime onlyDays(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime onlyMinutes(DateTime date) =>
    DateTime(date.year, date.month, date.day, date.hour, date.minute);
int compareTimeOfDay(DateTime date, DateTime otherDate) {
  int hourDiff = date.hour.compareTo(otherDate.hour);
  if (hourDiff != 0) return hourDiff;
  return date.minute.compareTo(otherDate.minute);
}

bool isAtSameDay(DateTime date1, DateTime date2) =>
    onlyDays(date1).isAtSameMomentAs(onlyDays(date2));
bool isDayBefore(DateTime date1, DateTime date2) =>
    onlyDays(date1).isBefore(onlyDays(date2));

bool onOrBetween(
        {@required DateTime dayInQuestion,
        @required DateTime startDate,
        @required DateTime endDate}) =>
    (dayInQuestion.isAfter(startDate) && dayInQuestion.isBefore(endDate)) ||
    dayInQuestion.isAtSameMomentAs(startDate) ||
    dayInQuestion.isAtSameMomentAs(endDate);

// ISO 8601 states:
// - Week 1 is the week with the first thursday of that year.
// - 4 of january is always in week 1
int getWeekNumber(DateTime d) {
  final day = onlyDays(d);
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
