import 'package:meta/meta.dart';

import 'package:flutter/widgets.dart';

import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

extension RecursExtensions on RecurrentType {
  IconData iconData() {
    switch (this) {
      case RecurrentType.weekly:
        return AbiliaIcons.week;
      case RecurrentType.monthly:
        return AbiliaIcons.month;
      case RecurrentType.yearly:
        return AbiliaIcons.basic_activity;
      default:
        return AbiliaIcons.day;
    }
  }

  String text(Translated translator) {
    switch (this) {
      case RecurrentType.weekly:
        return translator.weekly;
      case RecurrentType.monthly:
        return translator.monthly;
      case RecurrentType.yearly:
        return translator.yearly;
      default:
        return translator.once;
    }
  }
}

@visibleForTesting
bool onCorrectWeeklyDay(int recurrentData, DateTime date) {
  final isOddWeek = date.getWeekNumber().isOdd;
  final leadingZeros = date.weekday - 1 + (isOddWeek ? 7 : 0);
  return _isBitSet(recurrentData, leadingZeros);
}

@visibleForTesting
bool onCorrectMonthDay(int recurrentData, DateTime day) =>
    _isBitSet(recurrentData, day.day - 1);

bool _isBitSet(int recurrentData, int bit) => recurrentData & (1 << bit) > 0;

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
        startDate: startTime.onlyDays(), endDate: recurs.end.onlyDays())) {
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

extension RecursToList on Recurs {
  Set<int> get weekDays => recurrance == RecurrentType.weekly
      ? _generateBitsSet(DateTime.daysPerWeek)
      : {};

  Set<int> get monthDays =>
      recurrance == RecurrentType.monthly ? _generateBitsSet(31) : {};

  Set<int> _generateBitsSet(int bits) =>
      List.generate(bits, (bit) => bit, growable: false)
          .where((bit) => _isBitSet(data, bit))
          .map((bit) => bit + 1)
          .toSet();
}
