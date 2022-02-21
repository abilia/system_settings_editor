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

  List<ActivityDay> nightActivitiesForDay(DateTime day, DayParts dayParts) =>
      nightActivitiesForNight(
        day,
        dayParts.nightBegins(day),
        dayParts.nightEnd(day),
      );

  List<ActivityDay> nightActivitiesForNight(
    DateTime day,
    DateTime nightStart,
    DateTime nightEnd,
  ) {
    // Don't care about full days on night
    if (fullDay) {
      return const [];
    }

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

    if (startTime.isAfter(nightEnd) || startTime.isAfter(recurs.end)) {
      return const [];
    }

    if (recurs.end.isBefore(nightStart)) {
      return [
        if (endClock(day).isAfter(nightStart) &&
            recursOnNight(
              nightStart,
              day,
              nightStart,
              nightEnd,
            ))
          ActivityDay(this, day)
      ];
    }

    if (nightStart.isBefore(startTime)) {
      final nextDay = day.nextDay();
      return [
        if (startClock(nextDay).isAfter(nightStart) &&
            recursOnNight(
              nightStart,
              nextDay,
              nightStart,
              nightEnd,
            ))
          ActivityDay(this, nextDay)
      ];
    }

    return [
      for (var dayIterator = nightStart.subtract(duration).onlyDays(),
              start = startClock(dayIterator);
          start.isBefore(nightEnd);
          dayIterator = dayIterator.nextDay(), start = startClock(dayIterator))
        if (recursOnNight(
          start,
          dayIterator,
          nightStart,
          nightEnd,
        ))
          ActivityDay(this, dayIterator)
    ];
  }

  bool recursOnDay(DateTime day) => recurs.recursOnDay(day);

  bool recursOnNight(
    DateTime startClock,
    DateTime day,
    DateTime nightStart,
    DateTime nightEnd,
  ) =>
      recursOnDay(day) &&
      (startClock.inRangeWithInclusiveStart(
            startDate: nightStart,
            endDate: nightEnd,
          ) ||
          nightStart.inExclusiveRange(
            startDate: startClock,
            endDate: endClock(day),
          ));
}
