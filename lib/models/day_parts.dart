import 'package:equatable/equatable.dart';

enum DayPart { morning, day, evening, night }

class DayParts extends Equatable {
  static const int morningDefault = 6 * Duration.millisecondsPerHour,
      dayDefault = 10 * Duration.millisecondsPerHour,
      afternoonDefault = 12 * Duration.millisecondsPerHour,
      eveningDefault = 18 * Duration.millisecondsPerHour,
      nightDefault = 23 * Duration.millisecondsPerHour;

  static const limits = {
    DayPart.morning: _DayPartRange(5, 10),
    DayPart.day: _DayPartRange(8, 18),
    DayPart.evening: _DayPartRange(16, 21),
    DayPart.night: _DayPartRange(19, 24),
  };

  Duration get morning => Duration(milliseconds: morningStart);
  Duration get night => Duration(milliseconds: nightStart);

  final int morningStart, dayStart, eveningStart, nightStart;

  factory DayParts.standard() => DayParts(
        DayParts.morningDefault,
        DayParts.dayDefault,
        DayParts.eveningDefault,
        DayParts.nightDefault,
      );

  DayParts(
    this.morningStart,
    this.dayStart,
    this.eveningStart,
    this.nightStart,
  )   : assert(morningStart >= limits[DayPart.morning]!.min),
        assert(morningStart <= limits[DayPart.morning]!.max),
        assert(morningStart <= dayStart - Duration.millisecondsPerHour),
        assert(dayStart >= limits[DayPart.day]!.min),
        assert(dayStart <= limits[DayPart.day]!.max),
        assert(dayStart <= eveningStart - Duration.millisecondsPerHour),
        assert(eveningStart >= limits[DayPart.evening]!.min),
        assert(eveningStart <= limits[DayPart.evening]!.max),
        assert(eveningStart <= nightStart - Duration.millisecondsPerHour),
        assert(nightStart >= limits[DayPart.night]!.min),
        assert(nightStart <= limits[DayPart.night]!.max);

  int fromDayPart(DayPart dayPart) {
    switch (dayPart) {
      case DayPart.morning:
        return morningStart;
      case DayPart.day:
        return dayStart;
      case DayPart.evening:
        return eveningStart;
      case DayPart.night:
        return nightStart;
      default:
        throw ArgumentError(dayPart);
    }
  }

  @override
  List<Object> get props => [
        morningStart,
        dayStart,
        eveningStart,
        nightStart,
      ];
}

class _DayPartRange {
  final int min, max;
  int clamp(int value) => value.clamp(min, max);
  const _DayPartRange(int min, int max)
      : assert(min >= 0),
        assert(min < max),
        assert(max <= Duration.millisecondsPerDay),
        min = min * Duration.millisecondsPerHour,
        max = max * Duration.millisecondsPerHour;
}
