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
