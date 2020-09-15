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
      if (recursOnDay(day)) {
        return [ActivityDay(this, day)];
      }
      return [];
    }

    final result = <ActivityDay>[];
    for (var dayIterator = day;
        endClock(dayIterator).isAfter(day);
        dayIterator = dayIterator.previousDay()) {
      if (recursOnDay(dayIterator)) {
        result.add(ActivityDay(this, dayIterator));
      }
    }
    return result;
  }

  bool recursOnDay(DateTime day) {
    return recurs.recursOnDay(day);
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
          .where((bit) => Recurs.isBitSet(data, bit))
          .map((bit) => bit + 1)
          .toSet();
}
