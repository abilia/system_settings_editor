import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

@visibleForTesting
bool onCorrectWeeklyDay(int recurrentData, DateTime date) {
  final isOddWeek = date.getWeekNumber().isOdd;
  final leadingZeros = date.weekday - 1 + (isOddWeek ? 7 : 0);
  final bitmask = 1 << leadingZeros;
  return recurrentData & bitmask > 0;
}

@visibleForTesting
bool onCorrectMonthDay(int recurrentData, DateTime day) {
  final bitmask = 1 << day.day - 1;
  return recurrentData & bitmask > 0;
}

@visibleForTesting
bool onCorrectYearsDay(int recurrentData, DateTime date) {
  final recurringDay = recurrentData % 100;
  final recurringMonth = recurrentData ~/ 100 + 1;
  return date.month == recurringMonth && date.day == recurringDay;
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
    switch (recurs.recurrance) {
      case RecurrentType.weekly:
        return onCorrectWeeklyDay(recurs.data, day);
      case RecurrentType.monthly:
        return onCorrectMonthDay(recurs.data, day);
      case RecurrentType.yearly:
        return onCorrectYearsDay(recurs.data, day);
      default:
        return false;
    }
  }
}
