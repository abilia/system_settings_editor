part of 'memoplanner_setting_bloc.dart';

abstract class MemoplannerSettingsState {
  final MemoplannerSettings settings;
  const MemoplannerSettingsState(this.settings);
  bool get displayAlarmButton => settings.displayAlarmButton;
  bool get displayDeleteButton => settings.displayDeleteButton;
  bool get displayEditButton => settings.displayEditButton;
  bool get displayQuarterHour => settings.displayQuarterHour;
  bool get displayTimeLeft => settings.displayTimeLeft;
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
  int get morningStart => settings.morningIntervalStart;
  int get forenoonStart => settings.forenoonIntervalStart;
  int get afternoonStart => settings.afternoonIntervalStart;
  int get eveningStart => settings.eveningIntervalStart;
  int get nightStart => settings.nightIntervalStart;
  DayParts get dayParts => DayParts(
      morningStart, forenoonStart, afternoonStart, eveningStart, nightStart);

  // Properties derived from one or more settings
  bool get abilityToSelectAlarm =>
      [
        settings.activityDisplayAlarmOption,
        settings.activityDisplaySilentAlarmOption,
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

class MemoplannerSettingsLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsLoaded(MemoplannerSettings settings) : super(settings);
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettingsState {
  MemoplannerSettingsNotLoaded() : super(MemoplannerSettings());
}

class DayParts {
  final int morningStart,
      forenoonStart,
      afternoonStart,
      eveningStart,
      nightStart;

  DayParts(
    this.morningStart,
    this.forenoonStart,
    this.afternoonStart,
    this.eveningStart,
    this.nightStart,
  );
}

enum DayPart { morning, forenoon, afternoon, evening, night }

class MemoplannerSettings {
  static const String displayAlarmButtonKey =
          'activity_detailed_setting_display_change_alarm_button',
      displayDeleteButtonKey =
          'activity_detailed_setting_display_delete_button',
      displayEditButtonKey = 'activity_detailed_setting_display_edit_button',
      displayQuarterHourKey = 'activity_detailed_setting_display_qhw',
      displayTimeLeftKey = 'activity_detailed_setting_display_qhw_time_left',
      activityDateEditableKey = 'advanced_activity_date',
      activityTypeEditableKey = 'advanced_activity_type',
      activityEndTimeEditableKey = 'add_activity_end_time',
      activityTimeBeforeCurrentKey = 'add_activity_time_before_current',
      activityRecurringEditableKey = 'add_activity_recurring_step',
      activityDisplayAlarmOptionKey = 'add_activity_display_alarm',
      activityDisplaySilentAlarmOptionKey = 'add_activity_display_silent_alarm',
      activityDisplayNoAlarmOptionKey = 'add_activity_display_no_alarm',
      activityDisplayDayPeriodKey = 'day_caption_show_period',
      activityDisplayWeekDayKey = 'day_caption_show_weekday',
      morningIntervalStartKey = 'morning_interval_start',
      forenoonIntervalStartKey = 'forenoon_interval_start',
      afternoonIntervalStartKey = 'afternoon_interval_start',
      eveningIntervalStartKey = 'evening_interval_start',
      nightIntervalStartKey = 'night_interval_start';

  final bool displayAlarmButton,
      displayDeleteButton,
      displayEditButton,
      displayQuarterHour,
      displayTimeLeft,
      activityDateEditable,
      activityTypeEditable,
      activityEndTimeEditable,
      activityTimeBeforeCurrent,
      activityRecurringEditable,
      activityDisplayAlarmOption,
      activityDisplaySilentAlarmOption,
      activityDisplayNoAlarmOption,
      activityDisplayDayPeriod,
      activityDisplayWeekDay;

  final int morningIntervalStart,
      forenoonIntervalStart,
      afternoonIntervalStart,
      eveningIntervalStart,
      nightIntervalStart;

  MemoplannerSettings({
    this.displayAlarmButton = true,
    this.displayDeleteButton = true,
    this.displayEditButton = true,
    this.displayQuarterHour = true,
    this.displayTimeLeft = true,
    this.activityDateEditable = true,
    this.activityTypeEditable = true,
    this.activityEndTimeEditable = true,
    this.activityTimeBeforeCurrent = true,
    this.activityRecurringEditable = true,
    this.activityDisplayAlarmOption = true,
    this.activityDisplaySilentAlarmOption = true,
    this.activityDisplayNoAlarmOption = true,
    this.activityDisplayDayPeriod = true,
    this.activityDisplayWeekDay = true,
    this.morningIntervalStart = 21600000,
    this.forenoonIntervalStart = 36000000,
    this.afternoonIntervalStart = 43200000,
    this.eveningIntervalStart = 64800000,
    this.nightIntervalStart = 82800000,
  });

  factory MemoplannerSettings.fromSettingsList(
      List<MemoplannerSettingData> settings) {
    return _parseSettings(settings);
  }

  static MemoplannerSettings _parseSettings(
      List<MemoplannerSettingData> settings) {
    return MemoplannerSettings(
      displayAlarmButton: _parseSetting(displayAlarmButtonKey, settings, true),
      displayDeleteButton:
          _parseSetting(displayDeleteButtonKey, settings, true),
      displayEditButton: _parseSetting(displayEditButtonKey, settings, true),
      displayQuarterHour: _parseSetting(displayQuarterHourKey, settings, true),
      displayTimeLeft: _parseSetting(displayTimeLeftKey, settings, true),
      activityDateEditable:
          _parseSetting(activityDateEditableKey, settings, true),
      activityTypeEditable:
          _parseSetting(activityTypeEditableKey, settings, true),
      activityEndTimeEditable:
          _parseSetting(activityEndTimeEditableKey, settings, true),
      activityTimeBeforeCurrent:
          _parseSetting(activityTimeBeforeCurrentKey, settings, true),
      activityRecurringEditable:
          _parseSetting(activityRecurringEditableKey, settings, true),
      activityDisplayAlarmOption:
          _parseSetting(activityDisplayAlarmOptionKey, settings, true),
      activityDisplaySilentAlarmOption:
          _parseSetting(activityDisplaySilentAlarmOptionKey, settings, true),
      activityDisplayNoAlarmOption:
          _parseSetting(activityDisplayNoAlarmOptionKey, settings, true),
      activityDisplayDayPeriod:
          _parseSetting(activityDisplayDayPeriodKey, settings, true),
      activityDisplayWeekDay:
          _parseSetting(activityDisplayWeekDayKey, settings, true),
      morningIntervalStart:
          _parseSetting(morningIntervalStartKey, settings, 21600000),
      forenoonIntervalStart:
          _parseSetting(forenoonIntervalStartKey, settings, 36000000),
      afternoonIntervalStart:
          _parseSetting(afternoonIntervalStartKey, settings, 43200000),
      eveningIntervalStart:
          _parseSetting(eveningIntervalStartKey, settings, 64800000),
      nightIntervalStart:
          _parseSetting(nightIntervalStartKey, settings, 82800000),
    );
  }

  static T _parseSetting<T>(String settingName,
      List<MemoplannerSettingData> rawSettings, T defaultValue) {
    final setting = rawSettings.firstWhere((s) => s.identifier == settingName,
        orElse: () => null);
    if (setting == null) {
      return defaultValue;
    }
    return json.decode(setting.data);
  }
}
