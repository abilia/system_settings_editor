//TODO(bornold) make these extensions methods

DateTime removeToDays(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime removeToMinutes(DateTime date) => DateTime(date.year, date.month, date.day, date.hour, date.minute);

bool isAtSameDay(DateTime date1, DateTime date2) => removeToDays(date1).isAtSameMomentAs(removeToDays(date2));
bool isDayBefore(DateTime date1, DateTime date2) => removeToDays(date1).isBefore(removeToDays(date2));



// ISO 8601 states:
// - Week 1 is the week with the first thursday of that year.
// - 4 of january is always in week 1
getWeekNumber(DateTime d) {
  final day = removeToDays(d);
  final january4th = DateTime(day.year, 1, 4);
  final mondayWeek1 = january4th.subtract(Duration(days: january4th.weekday));
  final mondayWeekx = day.subtract(Duration(days: day.weekday - 1));
  final diff = mondayWeekx.difference(mondayWeek1).inDays;
  final week = (diff / 7).floor() + 1;
  final thursdayWeekx = mondayWeekx.add(Duration(days: 3));
  if (week == 53 && thursdayWeekx.month == 1) return 1;
  return week;
}