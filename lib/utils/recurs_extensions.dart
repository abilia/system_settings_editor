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
      return [
        if (
        // Either if start time is on start day
        day.isAtSameDay(startTime) ||
            // or the activities spans over this midnight
            (!fullDay &&
                day.inExclusiveRange(
                  startDate: startTime,
                  endDate: noneRecurringEnd,
                )))
          ActivityDay(this, startTime.onlyDays())
      ];
    }

    // If the day is fully outside the span of the recurring
    if (!day.inInclusiveRange(
      startDate: startTime.onlyDays(),
      endDate: recurs.end.onlyDays(),
    )) {
      return const [];
    }

    if (fullDay) {
      return [
        if (recursOnDay(day)) ActivityDay(this, day),
      ];
    }

    return [
      // Starting with this day, we step back one day
      for (var dayIterator = day;
          // until the end time of this recurring acitvity is before the start of the day
          endClock(dayIterator).isAfter(day);
          dayIterator = dayIterator.previousDay())
        // Add if this day recurs on that day
        if (recursOnDay(dayIterator)) ActivityDay(this, dayIterator)
    ];
  }

  List<ActivityDay> nightActivitiesForDay(DateTime day, DayParts dayParts) {
    // Don't care about full days on night
    if (fullDay) {
      return const [];
    }

    final nextDay = day.nextDay();
    final nightEnd = nextDay.add(dayParts.morning);
    final nightStart = day.add(dayParts.night);

    if (!isRecurring) {
      return [
        if (startTime.inExclusiveRange(
              startDate: nightStart,
              endDate: nightEnd,
            ) ||
            noneRecurringEnd.inExclusiveRange(
              startDate: nightStart,
              endDate: nightEnd,
            ))
          ActivityDay(this, startTime.onlyDays())
      ];
    }

    // If the day is fully outside the span of the recurring
    if (recurs.end.isBefore(nightStart) || startTime.isAfter(nightEnd)) {
      return const [];
    }

    return [
      // Starting with this next day, we step back one day
      for (var dayIterator = nextDay;
          // until the end time of this recurring acitvity is before the start of the day
          day.isAfter(endClock(dayIterator));
          dayIterator = dayIterator.previousDay())

        // Add if this day recurs on that day
        if (recursOnDay(day) &&
            recursOnNight(dayIterator, nightStart, nightEnd))
          ActivityDay(this, dayIterator)
    ];
  }

  bool recursOnDay(DateTime day) {
    return recurs.recursOnDay(day);
  }

  bool recursOnNight(DateTime day, DateTime nightStart, DateTime nightEnd) {
    return startClock(day)
            .inExclusiveRange(startDate: nightStart, endDate: nightEnd) ||
        endClock(day)
            .inExclusiveRange(startDate: nightStart, endDate: nightEnd);
  }
}
