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
      ODD_SUNDAY = 0x2000;

  static const NO_END = 253402297199000;

  static int onDayOfMonth(int dayOfMonth) => 1 << (dayOfMonth - 1);
  static int onDaysOfMonth(List<int> daysOfMonth) =>
      daysOfMonth.fold(0, (ds, d) => ds | onDayOfMonth(d));
  static int dayOfYearData(DateTime date) => (date.month - 1) * 100 + date.day;

  @visibleForTesting
  static bool onCorrectWeeklyDay(int recurrentData, DateTime date) {
    bool isOddWeek = date.getWeekNumber().isOdd;
    int leadingZeros = date.weekday - 1 + (isOddWeek ? 7 : 0);
    int bitmask = 1 << leadingZeros;
    return recurrentData & bitmask > 0;
  }

  @visibleForTesting
  static bool onCorrectMonthDay(int recurrentData, DateTime day) {
    int bitmask = 1 << day.day - 1;
    return recurrentData & bitmask > 0;
  }

  @visibleForTesting
  static bool onCorrectYearsDay(int recurrentData, DateTime date) {
    int recurringDay = recurrentData % 100;
    int recurringMonth = recurrentData ~/ 100 + 1;
    return date.month == recurringMonth && date.day == recurringDay;
  }
}

extension RecurringActivityExtension on Activity {
  bool shouldShowForDay(DateTime day) {
    if (!isRecurring) {
      return day.isAtSameDay(start);
    }

    if (!day.onOrBetween(
        startDate: start.onlyDays(), endDate: recurringEnd.onlyDays())) {
      return false;
    }

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
