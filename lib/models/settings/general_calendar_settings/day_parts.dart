import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/datetime.dart';

enum DayPart { morning, day, evening, night }

class DayParts extends Equatable {
  static const morningIntervalStartKey = 'morning_interval_start',
      forenoonIntervalStartKey = 'forenoon_interval_start',
      eveningIntervalStartKey = 'evening_interval_start',
      nightIntervalStartKey = 'night_interval_start';

  static const int morningDefault = 6 * Duration.millisecondsPerHour,
      dayDefault = 10 * Duration.millisecondsPerHour,
      afternoonDefault = 12 * Duration.millisecondsPerHour,
      eveningDefault = 18 * Duration.millisecondsPerHour,
      nightDefault = 23 * Duration.millisecondsPerHour;

  static const morningLimit = _DayPartRange(5, 10),
      dayLimit = _DayPartRange(8, 18),
      eveningLimit = _DayPartRange(16, 21),
      nightLimit = _DayPartRange(19, 24);

  static const limits = {
    DayPart.morning: morningLimit,
    DayPart.day: dayLimit,
    DayPart.evening: eveningLimit,
    DayPart.night: nightLimit,
  };

  Duration get morning => Duration(milliseconds: morningStart);
  Duration get night => Duration(milliseconds: nightStart);
  Duration get evening => Duration(milliseconds: eveningStart);

  final int morningStart, dayStart, eveningStart, nightStart;

  const DayParts({
    this.morningStart = morningDefault,
    this.dayStart = dayDefault,
    this.eveningStart = eveningDefault,
    this.nightStart = nightDefault,
  });

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
    }
  }

  DateTime nightEnd(DateTime day) => day.nextDay().add(morning);
  DateTime nightBegins(DateTime day) => day.add(night);

  bool atMax(DayPart part) => fromDayPart(part) >= DayParts.limits[part]!.max;
  bool atMin(DayPart part) => fromDayPart(part) <= DayParts.limits[part]!.min;

  factory DayParts.fromSettingsMap(
    Map<String, MemoplannerSettingData> settings,
  ) =>
      DayParts(
        morningStart: settings.parse(
          morningIntervalStartKey,
          DayParts.morningDefault,
        ),
        dayStart: settings.parse(
          forenoonIntervalStartKey,
          DayParts.dayDefault,
        ),
        eveningStart: settings.parse(
          eveningIntervalStartKey,
          DayParts.eveningDefault,
        ),
        nightStart: settings.parse(
          nightIntervalStartKey,
          DayParts.nightDefault,
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: morningStart,
          identifier: DayParts.morningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: dayStart,
          identifier: DayParts.forenoonIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: eveningStart,
          identifier: DayParts.eveningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: nightStart,
          identifier: DayParts.nightIntervalStartKey,
        ),
      ];

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
