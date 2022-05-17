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
        return AbiliaIcons.basicActivity;
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
      return [
        if (day.isAtSameDay(startTime) ||
            (!fullDay &&
                day.inExclusiveRange(
                  startDate: startTime,
                  endDate: noneRecurringEnd,
                )))
          ActivityDay(this, startTime.onlyDays())
      ];
    }

    if (!day.inInclusiveRangeDay(
      startDate: startTime,
      endDate: fullDay ? recurs.end : endClock(recurs.end),
    )) {
      return const [];
    }

    if (fullDay) {
      return [
        if (recursOnDay(day)) ActivityDay(this, day),
      ];
    }

    if (day.isAfter(recurs.end)) {
      final previusDay = day.previousDay();
      return [
        if (recursOnDay(previusDay)) ActivityDay(this, previusDay),
      ];
    }

    final startDay = startTime.onlyDays();
    return [
      for (var dayIterator = day;
          endClock(dayIterator).isAtSameMomentOrAfter(day) &&
              dayIterator.isAtSameMomentOrAfter(startDay);
          dayIterator = dayIterator.previousDay())
        if (recursOnDay(dayIterator)) ActivityDay(this, dayIterator)
    ];
  }

  List<ActivityDay> dayActivitiesForInterval(
    DateTime intervalStart,
    DateTime intervalEnd,
  ) {
    final numberOfDays =
        intervalEnd.onlyDays().difference(intervalStart.onlyDays()).inDays + 1;
    final days = List.generate(
      numberOfDays,
      (i) => DateTime(
        intervalStart.year,
        intervalStart.month,
        intervalStart.day + i,
      ),
    );

    return days.expand((day) => dayActivitiesForDay(day)).toList();
  }

  bool recursOnDay(DateTime day) => recurs.recursOnDay(day);
}
