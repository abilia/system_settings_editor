import 'package:meta/meta.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

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

  static bool shouldShowForDay(Activity activity, DateTime day) {
    if (activity.recurrance == RecurrentType.none) {
      final activityStartTimeDay = onlyDays(activity.startDateTime);
      return day.isAtSameMomentAs(activityStartTimeDay);
    } 

    if (!onOrBetween(
        dayInQuestion: day,
        startDate: onlyDays(activity.startDateTime),
        endDate: onlyDays(activity.endDateTime))) {
      return false;
    }

    switch (activity.recurrance) {
      case RecurrentType.weekly:
        return onCorrectWeeklyDay(activity.recurrentData, day);
      case RecurrentType.monthly:
        return onCorrectMonthDay(activity.recurrentData, day);
      case RecurrentType.yearly:
        return onCorrectYearsDay(activity.recurrentData, day);
      default:
        return false;
    }
  }

  @visibleForTesting
  static bool onCorrectWeeklyDay(int recurrentData, DateTime date) {
    bool isOddWeek = getWeekNumber(date).isOdd;
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
