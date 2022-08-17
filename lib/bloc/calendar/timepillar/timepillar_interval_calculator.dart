part of 'timepillar_cubit.dart';

TimepillarInterval _todayTimepillarIntervalFromType(
  DateTime now,
  TimepillarIntervalType timepillarIntervalType,
  DayParts dayParts,
  DayPart dayPart,
) {
  final day = now.onlyDays();
  switch (timepillarIntervalType) {
    case TimepillarIntervalType.interval:
      return _dayPartInterval(now, dayParts, dayPart);
    case TimepillarIntervalType.day:
      if (now.isBefore(day.add(dayParts.morning))) {
        return TimepillarInterval(
          start: day.previousDay().add(dayParts.night),
          end: day.add(dayParts.morning),
          intervalPart: IntervalPart.night,
        );
      } else if (now.isAtSameMomentOrAfter(day.add(dayParts.night))) {
        return TimepillarInterval(
          start: day.add(dayParts.night),
          end: day.nextDay().add(dayParts.morning),
          intervalPart: IntervalPart.night,
        );
      }
      return TimepillarInterval(
        start: day.add(dayParts.morning),
        end: day.add(dayParts.night),
      );
    default:
      return TimepillarInterval(
        start: day,
        end: day.nextDay(),
        intervalPart: IntervalPart.dayAndNight,
      );
  }
}

TimepillarInterval _dayPartInterval(
  DateTime now,
  DayParts dayParts,
  DayPart part,
) {
  final base = now.onlyDays();
  switch (part) {
    case DayPart.morning:
      return TimepillarInterval(
        start: base.add(dayParts.morning),
        end: base.add(dayParts.day),
      );
    case DayPart.day:
      return TimepillarInterval(
        start: base.add(dayParts.day),
        end: base.add(dayParts.evening),
      );
    case DayPart.evening:
      return TimepillarInterval(
        start: base.add(dayParts.evening),
        end: base.add(dayParts.night),
      );
    case DayPart.night:
      if (now.isBefore(base.add(dayParts.morning))) {
        return TimepillarInterval(
          start: base.previousDay().add(dayParts.night),
          end: base.add(dayParts.morning),
          intervalPart: IntervalPart.night,
        );
      } else {
        return TimepillarInterval(
          start: base.add(dayParts.night),
          end: base.nextDay().add(dayParts.morning),
          intervalPart: IntervalPart.night,
        );
      }
  }
}
