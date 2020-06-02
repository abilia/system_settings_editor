import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class Recurs {
  static const int EVEN_MONDAY = 0x1,
      EVEN_TUESDAY = 0x2,
      EVEN_WEDNESDAY = 0x4,
      EVEN_THURSDAY = 0x8,
      EVEN_FRIDAY = 0x10,
      EVEN_SATURDAY = 0x20,
      EVEN_SUNDAY = 0x40,
      ODD_MONDAY = 0x80,
      ODD_TUESDAY = 0x100,
      ODD_WEDNESDAY = 0x200,
      ODD_THURSDAY = 0x400,
      ODD_FRIDAY = 0x800,
      ODD_SATURDAY = 0x1000,
      ODD_SUNDAY = 0x2000,
      MONDAY = EVEN_MONDAY | ODD_MONDAY,
      TUESDAY = EVEN_TUESDAY | ODD_TUESDAY,
      WEDNESDAY = EVEN_WEDNESDAY | ODD_WEDNESDAY,
      THURSDAY = EVEN_THURSDAY | ODD_THURSDAY,
      FRIDAY = EVEN_FRIDAY | ODD_FRIDAY,
      SATURDAY = EVEN_SATURDAY | ODD_SATURDAY,
      SUNDAY = EVEN_SUNDAY | ODD_SUNDAY,
      oddWeekdays = Recurs.ODD_MONDAY |
          Recurs.ODD_TUESDAY |
          Recurs.ODD_WEDNESDAY |
          Recurs.ODD_THURSDAY |
          Recurs.ODD_FRIDAY,
      evenWeekdays = Recurs.EVEN_MONDAY |
          Recurs.EVEN_TUESDAY |
          Recurs.EVEN_WEDNESDAY |
          Recurs.EVEN_THURSDAY |
          Recurs.EVEN_FRIDAY,
      allWeekdays = oddWeekdays | evenWeekdays,
      oddWeekends = Recurs.ODD_SATURDAY | Recurs.ODD_SUNDAY,
      evenWeekends = Recurs.EVEN_SATURDAY | Recurs.EVEN_SUNDAY,
      allWeekends = evenWeekends | oddWeekends,
      everyday = allWeekdays | allWeekends;

  static final DateTime NO_END =
      DateTime.fromMillisecondsSinceEpoch(253402297199000);

  static int onDayOfMonth(int dayOfMonth) => 1 << (dayOfMonth - 1);
  static int onDaysOfMonth(List<int> daysOfMonth) =>
      daysOfMonth.fold(0, (ds, d) => ds | onDayOfMonth(d));
  static int dayOfYearData(DateTime date) => (date.month - 1) * 100 + date.day;

  @visibleForTesting
  static bool onCorrectWeeklyDay(int recurrentData, DateTime date) {
    final isOddWeek = date.getWeekNumber().isOdd;
    final leadingZeros = date.weekday - 1 + (isOddWeek ? 7 : 0);
    final bitmask = 1 << leadingZeros;
    return recurrentData & bitmask > 0;
  }

  @visibleForTesting
  static bool onCorrectMonthDay(int recurrentData, DateTime day) {
    final bitmask = 1 << day.day - 1;
    return recurrentData & bitmask > 0;
  }

  @visibleForTesting
  static bool onCorrectYearsDay(int recurrentData, DateTime date) {
    final recurringDay = recurrentData % 100;
    final recurringMonth = recurrentData ~/ 100 + 1;
    return date.month == recurringMonth && date.day == recurringDay;
  }
}

extension RecurringActivityExtension on Activity {
  List<ActivityDay> dayActivitiesForDay(DateTime day) {
    if (!isRecurring) {
      if (day.isAtSameDay(startTime) ||
          day.inExclusiveRange(
              startDate: startTime, endDate: noneRecurringEnd)) {
        return [ActivityDay(this, startTime.onlyDays())];
      }
      return [];
    }

    if (!day.inInclusiveRange(
        startDate: startTime.onlyDays(), endDate: endTime.onlyDays())) {
      return [];
    }

    if (fullDay) {
      if (onCorrectRecurrance(day)) {
        return [ActivityDay(this, day)];
      }
      return [];
    }

    final result = <ActivityDay>[];
    for (var dayIterator = day;
        endClock(dayIterator).isAfter(day);
        dayIterator = dayIterator.previousDay()) {
      if (onCorrectRecurrance(dayIterator)) {
        result.add(ActivityDay(this, dayIterator));
      }
    }
    return result;
  }

  bool onCorrectRecurrance(DateTime day) {
    switch (recurrance) {
      case RecurrentType.weekly:
        return Recurs.onCorrectWeeklyDay(recurrentData, day);
      case RecurrentType.monthly:
        return Recurs.onCorrectMonthDay(recurrentData, day);
      case RecurrentType.yearly:
        return Recurs.onCorrectYearsDay(recurrentData, day);
      default:
        return false;
    }
  }
}
