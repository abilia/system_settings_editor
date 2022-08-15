import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/datetime.dart';

enum DayPart { morning, day, evening, night }

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

  DateTime nightEnd(DateTime day) => day.nextDay().add(morning);
  DateTime nightBegins(DateTime day) => day.add(night);

  bool atMax(DayPart part) => fromDayPart(part) >= DayParts.limits[part]!.max;
  bool atMin(DayPart part) => fromDayPart(part) <= DayParts.limits[part]!.min;

  TimepillarInterval todayTimepillarIntervalFromType(
      DateTime now, TimepillarIntervalType timepillarIntervalType) {
    final day = now.onlyDays();
    switch (timepillarIntervalType) {
      case TimepillarIntervalType.interval:
        return dayPartInterval(now);
      case TimepillarIntervalType.day:
        if (now.isBefore(day.add(morning))) {
          return TimepillarInterval(
            start: day.previousDay().add(night),
            end: day.add(morning),
            intervalPart: IntervalPart.night,
          );
        } else if (now.isAtSameMomentOrAfter(day.add(night))) {
          return TimepillarInterval(
            start: day.add(night),
            end: day.nextDay().add(morning),
            intervalPart: IntervalPart.night,
          );
        }
        return TimepillarInterval(
          start: day.add(morning),
          end: day.add(night),
        );
      default:
        return TimepillarInterval(
          start: day,
          end: day.nextDay(),
          intervalPart: IntervalPart.dayAndNight,
        );
    }
  }

  TimepillarInterval dayPartInterval(DateTime now) {
    final part = now.dayPart(this);
    final base = now.onlyDays();
    switch (part) {
      case DayPart.morning:
        return TimepillarInterval(
          start: base.add(morning),
          end: base.add(day),
        );
      case DayPart.day:
        return TimepillarInterval(
          start: base.add(day),
          end: base.add(evening),
        );
      case DayPart.evening:
        return TimepillarInterval(
          start: base.add(evening),
          end: base.add(night),
        );
      case DayPart.night:
        if (now.isBefore(base.add(morning))) {
          return TimepillarInterval(
            start: base.previousDay().add(night),
            end: base.add(morning),
            intervalPart: IntervalPart.night,
          );
        } else {
          return TimepillarInterval(
            start: base.add(night),
            end: base.nextDay().add(morning),
            intervalPart: IntervalPart.night,
          );
        }
    }
  }

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
