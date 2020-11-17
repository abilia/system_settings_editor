part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsState {
  final MemoplannerSettings settings;
  const MemoplannerSettingsState(this.settings);
  bool get displayAlarmButton => settings.displayAlarmButton;
  bool get displayDeleteButton => settings.displayDeleteButton;
  bool get displayEditButton => settings.displayEditButton;
  bool get displayQuarterHour => settings.displayQuarterHour;
  bool get displayTimeLeft => settings.displayTimeLeft;
  bool get dayCaptionShowDayButtons => settings.dayCaptionShowDayButtons;
  bool get activityDateEditable => settings.activityDateEditable;
  bool get activityTypeEditable => settings.activityTypeEditable;
  bool get activityEndTimeEditable => settings.activityEndTimeEditable;
  bool get activityTimeBeforeCurrent => settings.activityTimeBeforeCurrent;
  bool get activityRecurringEditable => settings.activityRecurringEditable;
  bool get activityDisplayAlarmOption => settings.activityDisplayAlarmOption;
  bool get activityDisplaySilentAlarmOption =>
      settings.activityDisplaySilentAlarmOption;
  bool get activityDisplayNoAlarmOption =>
      settings.activityDisplayNoAlarmOption;
  bool get activityDisplayDayPeriod => settings.activityDisplayDayPeriod;
  bool get activityDisplayWeekDay => settings.activityDisplayWeekDay;
  bool get activityDisplayDate => settings.activityDisplayDate;
  bool get showCategories => settings.calendarActivityTypeShowTypes;
  HourClockType get timepillarHourClockType =>
      _hourClockTypeFromNullBool(settings.setting12hTimeFormatTimeline);
  bool get displayHourLines => settings.settingDisplayHourLines;
  bool get displayTimeline => settings.settingDisplayTimeline;

  int get morningStart => settings.morningIntervalStart;
  int get forenoonStart => settings.forenoonIntervalStart;
  int get afternoonStart => settings.afternoonIntervalStart;
  int get eveningStart => settings.eveningIntervalStart;
  int get nightStart => settings.nightIntervalStart;
  int get calendarDayColor => settings.calendarDayColor;
  TimepillarIntervalType get timepillarIntervalType =>
      TimepillarIntervalType.values[settings.viewOptionsTimeInterval];

  TimepillarInterval todayTimepillarInterval(DateTime now) {
    final day = now.onlyDays();
    switch (timepillarIntervalType) {
      case TimepillarIntervalType.INTERVAL:
        return dayPartInterval(now);
      case TimepillarIntervalType.DAY:
        return TimepillarInterval(
          startTime: day.add(morningStart.milliseconds()),
          endTime: day.add(nightStart.milliseconds()),
        );
      default:
        return TimepillarInterval(
          startTime: day,
          endTime: day.nextDay(),
        );
    }
  }

  TimepillarInterval dayPartInterval(DateTime now) {
    final part = now.dayPart(dayParts);
    final base = now.onlyDays();
    switch (part) {
      case DayPart.morning:
        return TimepillarInterval(
          startTime: base.add(morningStart.milliseconds()),
          endTime: base.add(forenoonStart.milliseconds()),
        );
      case DayPart.forenoon:
        return TimepillarInterval(
          startTime: base.add(forenoonStart.milliseconds()),
          endTime: base.add(afternoonStart.milliseconds()),
        );
      case DayPart.afternoon:
        return TimepillarInterval(
          startTime: base.add(afternoonStart.milliseconds()),
          endTime: base.add(eveningStart.milliseconds()),
        );
      case DayPart.evening:
        return TimepillarInterval(
          startTime: base.add(eveningStart.milliseconds()),
          endTime: base.add(nightStart.milliseconds()),
        );
      case DayPart.night:
        if (now.isBefore(base.add(morningStart.milliseconds()))) {
          return TimepillarInterval(
            startTime: base,
            endTime: base.add(morningStart.milliseconds()),
          );
        } else {
          return TimepillarInterval(
            startTime: base.add(nightStart.milliseconds()),
            endTime: base.nextDay(),
          );
        }
    }
    throw ArgumentError();
  }

  DayParts get dayParts => DayParts(
        morningStart,
        forenoonStart,
        afternoonStart,
        eveningStart,
        nightStart,
      );

  String get leftCategoryName => settings.calendarActivityTypeLeft;
  String get rightCategoryName => settings.calendarActivityTypeRight;

  // Properties derived from one or more settings
  bool get abilityToSelectAlarm =>
      [
        settings.activityDisplayAlarmOption,
        settings.activityDisplaySilentAlarmOption, // for Vibration
        settings.activityDisplaySilentAlarmOption, // and Silent
        settings.activityDisplayNoAlarmOption
      ].where((e) => e).length >=
      2;

  int defaultAlarmType() {
    if (settings.activityDisplayAlarmOption) {
      return ALARM_SOUND_AND_VIBRATION;
    }
    if (settings.activityDisplaySilentAlarmOption) {
      return ALARM_VIBRATION;
    }
    if (settings.activityDisplayNoAlarmOption) {
      return NO_ALARM;
    }
    return ALARM_SOUND_AND_VIBRATION;
  }
}

HourClockType _hourClockTypeFromNullBool(bool value) => value == null
    ? HourClockType.useSystem
    : value
        ? HourClockType.use12
        : HourClockType.use24;

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsLoaded(MemoplannerSettings settings) : super(settings);
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsNotLoaded() : super(MemoplannerSettings());
}

enum TimepillarIntervalType {
  DAY_AND_NIGHT,
  INTERVAL,
  DAY,
}

class TimepillarInterval extends Equatable {
  final DateTime startTime, endTime;

  TimepillarInterval({
    this.startTime,
    this.endTime,
  });

  int get lengthInHours =>
      (endTime.difference(startTime).inMinutes / 60).ceil();

  List<ActivityOccasion> getForInterval(List<ActivityOccasion> activities) {
    return activities
        .where((a) =>
            a.start.inInclusiveRange(startDate: startTime, endDate: endTime) ||
            a.end.inInclusiveRange(startDate: startTime, endDate: endTime) ||
            (a.start.isBefore(startTime) && a.end.isAfter(endTime)))
        .toList();
  }

  @override
  List<Object> get props => [startTime, endTime];
}
