import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

enum DayPart { morning, day, evening, night }

extension DayPartExtension on DayPart {
  bool get isNight => this == DayPart.night;
  bool get isMorning => this == DayPart.morning;
}

class DayParts extends Equatable {
  static const morningIntervalStartKey = 'morning_interval_start',
      forenoonIntervalStartKey = 'forenoon_interval_start',
      eveningIntervalStartKey = 'evening_interval_start',
      nightIntervalStartKey = 'night_interval_start';

  static const int morningDefaultHour = 6,
      dayDefaultHour = 10,
      eveningDefaultHour = 18,
      nightDefaultHour = 23;
  static const Duration morningDefault = Duration(hours: morningDefaultHour),
      dayDefault = Duration(hours: dayDefaultHour),
      eveningDefault = Duration(hours: eveningDefaultHour),
      nightDefault = Duration(hours: nightDefaultHour);

  static const morningLimit =
          _DayPartRange(Duration(hours: 5), Duration(hours: 10)),
      dayLimit = _DayPartRange(Duration(hours: 8), Duration(hours: 18)),
      eveningLimit = _DayPartRange(Duration(hours: 16), Duration(hours: 21)),
      nightLimit = _DayPartRange(Duration(hours: 19), Duration(hours: 24));

  static const limits = {
    DayPart.morning: morningLimit,
    DayPart.day: dayLimit,
    DayPart.evening: eveningLimit,
    DayPart.night: nightLimit,
  };

  final Duration morning, day, night, evening;

  const DayParts({
    this.morning = morningDefault,
    this.day = dayDefault,
    this.evening = eveningDefault,
    this.night = nightDefault,
  });

  Duration fromDayPart(DayPart dayPart) {
    switch (dayPart) {
      case DayPart.morning:
        return morning;
      case DayPart.day:
        return day;
      case DayPart.evening:
        return evening;
      case DayPart.night:
        return night;
    }
  }

  bool atMax(DayPart part) => fromDayPart(part) >= DayParts.limits[part]!.max;
  bool atMin(DayPart part) => fromDayPart(part) <= DayParts.limits[part]!.min;

  factory DayParts.fromSettingsMap(
    Map<String, MemoplannerSettingData> settings,
  ) =>
      DayParts(
        morning: Duration(
          milliseconds: settings.parse(
            morningIntervalStartKey,
            DayParts.morningDefaultHour * Duration.millisecondsPerHour,
          ),
        ),
        day: Duration(
          milliseconds: settings.parse(
            forenoonIntervalStartKey,
            DayParts.dayDefaultHour * Duration.millisecondsPerHour,
          ),
        ),
        evening: Duration(
          milliseconds: settings.parse(
            eveningIntervalStartKey,
            DayParts.eveningDefaultHour * Duration.millisecondsPerHour,
          ),
        ),
        night: Duration(
          milliseconds: settings.parse(
            nightIntervalStartKey,
            DayParts.nightDefaultHour * Duration.millisecondsPerHour,
          ),
        ),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: morning.inMilliseconds,
          identifier: DayParts.morningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: day.inMilliseconds,
          identifier: DayParts.forenoonIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: evening.inMilliseconds,
          identifier: DayParts.eveningIntervalStartKey,
        ),
        MemoplannerSettingData.fromData(
          data: night.inMilliseconds,
          identifier: DayParts.nightIntervalStartKey,
        ),
      ];

  @override
  List<Object> get props => [
        morning,
        day,
        evening,
        night,
      ];
}

class _DayPartRange {
  final Duration min, max;
  Duration clamp(Duration value) => value < min
      ? min
      : value > max
          ? max
          : value;

  const _DayPartRange(this.min, this.max);
}
