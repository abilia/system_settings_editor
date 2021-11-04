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
      endDate: recurs.end,
    )) {
      return const [];
    }

    if (fullDay) {
      return [
        if (recursOnDay(day)) ActivityDay(this, day),
      ];
    }

    return [
      for (var dayIterator = day;
          endClock(dayIterator).isAtSameMomentOrAfter(day);
          dayIterator = dayIterator.previousDay())
        if (recursOnDay(dayIterator)) ActivityDay(this, dayIterator)
    ];
  }

  List<ActivityDay> nightActivitiesForDay(DateTime day, DayParts dayParts) {
    // Don't care about full days on night
    if (fullDay) {
      return const [];
    }

    final nightEnd = day.nextDay().add(dayParts.morning);
    final nightStart = day.add(dayParts.night);

    if (!isRecurring) {
      return [
        if (startTime.inRangeWithInclusiveStart(
              startDate: nightStart,
              endDate: nightEnd,
            ) ||
            nightStart.inExclusiveRange(
              startDate: startTime,
              endDate: endClock(day),
            ))
          ActivityDay(this, startTime.onlyDays())
      ];
    }

    if (recurs.end.isBefore(nightStart) || startTime.isAfter(nightEnd)) {
      return const [];
    }

    return [
      for (var dayIterator = nightStart.subtract(duration).onlyDays(),
              start = startClock(dayIterator);
          start.isBefore(nightEnd);
          dayIterator = dayIterator.nextDay(), start = startClock(dayIterator))
        if (recursOnDay(dayIterator) &&
            recursOnNight(
              start,
              endClock(dayIterator),
              nightStart,
              nightEnd,
            ))
          ActivityDay(this, dayIterator)
    ];
  }

  bool recursOnDay(DateTime day) => recurs.recursOnDay(day);

  bool recursOnNight(
    DateTime startClock,
    DateTime endClock,
    DateTime nightStart,
    DateTime nightEnd,
  ) =>
      startClock.inRangeWithInclusiveStart(
        startDate: nightStart,
        endDate: nightEnd,
      ) ||
      nightStart.inExclusiveRange(
        startDate: startClock,
        endDate: endClock,
      );
}
