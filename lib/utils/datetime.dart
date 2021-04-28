import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

final yMd = DateFormat('y-MM-dd').format;
final hm = DateFormat.Hm().format;

extension DateTimeExtensions on DateTime {
  DateTime onlyDays() => DateTime(year, month, day);

  DateTime onlyMinutes() => DateTime(year, month, day, hour, minute);

  DateTime nextDay() => copyWith(day: day + 1);
  DateTime addDays(int days) => copyWith(day: day + days);
  DateTime nextWeek() => copyWith(day: day + 7);
  DateTime previousWeek() => copyWith(day: day - 7);
  DateTime previousDay() => copyWith(day: day - 1);

  DateTime firstDayOfMonth() => DateTime(year, month, 1);
  DateTime nextMonth() => DateTime(year, month + 1, 1);
  DateTime previousMonth() => DateTime(year, month - 1, 1);

  DateTime millisecondBefore() =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch - 1);

  DateTime nextMinute() => DateTime(year, month, day, hour, minute + 1);

  DateTime roundToMinute(int minutesPerDot, int rounding) => DateTime(
        year,
        month,
        day,
        hour,
        minute % minutesPerDot > rounding
            ? ((minute ~/ minutesPerDot) + 1) * minutesPerDot
            : (minute ~/ minutesPerDot) * minutesPerDot,
      );

  DateTime firstInWeek() => subtract(Duration(days: weekday - 1)).onlyDays();

  DateTime copyWith(
          {int year,
          int month,
          int day,
          int hour,
          int minute,
          int second,
          int millisecond,
          int microsecond}) =>
      DateTime(
          year ?? this.year,
          month ?? this.month,
          day ?? this.day,
          hour ?? this.hour,
          minute ?? this.minute,
          second ?? this.second,
          millisecond ?? this.millisecond,
          microsecond ?? this.microsecond);

  bool isAtSameDay(DateTime otherDate) =>
      onlyDays().isAtSameMomentAs(otherDate.onlyDays());

  bool isSameWeek(DateTime otherDate) =>
      getWeekNumber() == otherDate.getWeekNumber();

  bool isDayBefore(DateTime otherDate) =>
      onlyDays().isBefore(otherDate.onlyDays());
  bool isDayAfter(DateTime otherDate) =>
      onlyDays().isAfter(otherDate.onlyDays());

  bool inInclusiveRange(
      {@required DateTime startDate, @required DateTime endDate}) {
    if (endDate.isBefore(startDate)) return false;
    if (isBefore(endDate) && isAfter(startDate)) return true;
    if (isAtSameMomentAs(startDate)) return true;
    if (isAtSameMomentAs(endDate)) return true;
    return false;
  }

  bool inRangeWithInclusiveStart(
      {@required DateTime startDate, @required DateTime endDate}) {
    if (endDate.isBefore(startDate)) return false;
    if (isBefore(endDate) && isAfter(startDate)) return true;
    if (isAtSameMomentAs(startDate)) return true;
    return false;
  }

  bool inExclusiveRange(
      {@required DateTime startDate, @required DateTime endDate}) {
    if (endDate.isBefore(startDate)) return false;
    if (isBefore(endDate) && isAfter(startDate)) return true;
    return false;
  }

  bool isAtSameMomentOrAfter(DateTime time) =>
      isAfter(time) || isAtSameMomentAs(time);

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

  Occasion occasion(DateTime now) => isAfter(now)
      ? Occasion.future
      : isBefore(now)
          ? Occasion.past
          : Occasion.current;

  DateTime withTime(TimeOfDay timeOfDay) =>
      copyWith(hour: timeOfDay.hour, minute: timeOfDay.minute);

  DayPart dayPart(DayParts dayParts) {
    final msAfterMidnight = difference(onlyDays()).inMilliseconds;

    if (msAfterMidnight >= dayParts.nightStart) return DayPart.night;

    if (msAfterMidnight >= dayParts.eveningStart) return DayPart.evening;

    if (msAfterMidnight >= dayParts.dayStart) return DayPart.day;

    if (msAfterMidnight >= dayParts.morningStart) return DayPart.morning;

    return DayPart.night;
  }

  bool isNight(DayParts dayParts) {
    return DayPart.night == dayPart(dayParts);
  }
}

extension IntDateTimeExtensions on int {
  DateTime fromMillisecondsSinceEpoch({bool isUtc = false}) =>
      DateTime.fromMillisecondsSinceEpoch(this, isUtc: isUtc);
}
