import 'package:calendar_events/calendar_events.dart';
import 'package:utils/utils.dart';

extension RecurringActivityExtension on Activity {
  List<ActivityDay> dayActivitiesForDay(
    DateTime day, {
    bool includeMidnight = false,
  }) {
    if (!isRecurring) {
      final range =
          includeMidnight ? day.inRangeWithInclusiveEnd : day.inExclusiveRange;
      return [
        if (day.isAtSameDay(startTime) ||
            (!fullDay &&
                range(
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

  bool recursOnDay(DateTime day) => recurs.recursOnDay(day);
}
