import 'dart:convert';

import 'package:seagull/models/all.dart';

class MemoplannerSettings {
  static const String displayAlarmButtonKey =
          'activity_detailed_setting_display_change_alarm_button',
      displayDeleteButtonKey =
          'activity_detailed_setting_display_delete_button',
      displayEditButtonKey = 'activity_detailed_setting_display_edit_button',
      displayQuarterHourKey = 'activity_detailed_setting_display_qhw',
      displayTimeLeftKey = 'activity_detailed_setting_display_qhw_time_left',
      dayCaptionShowDayButtonsKey = 'day_caption_show_day_buttons',
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
      activityDisplayDateKey = 'day_caption_show_date',
      morningIntervalStartKey = 'morning_interval_start',
      forenoonIntervalStartKey = 'forenoon_interval_start',
      afternoonIntervalStartKey = 'afternoon_interval_start',
      eveningIntervalStartKey = 'evening_interval_start',
      nightIntervalStartKey = 'night_interval_start',
      calendarActivityTypeLeftKey = 'calendar_activity_type_left',
      calendarActivityTypeRightKey = 'calendar_activity_type_right',
      calendarActivityTypeShowTypesKey = 'calendar_activity_type_show_types',
      calendarDayColorKey = 'calendar_daycolor',
      setting12hTimeFormatTimelineKey = 'setting_12h_time_format_timeline',
      settingDisplayHourLinesKey = 'setting_display_hour_lines',
      settingDisplayTimelineKey = 'setting_display_line_timeline';

  final bool displayAlarmButton,
      displayDeleteButton,
      displayEditButton,
      displayQuarterHour,
      displayTimeLeft,
      dayCaptionShowDayButtons,
      activityDateEditable,
      activityTypeEditable,
      activityEndTimeEditable,
      activityTimeBeforeCurrent,
      activityRecurringEditable,
      activityDisplayAlarmOption,
      activityDisplaySilentAlarmOption,
      activityDisplayNoAlarmOption,
      activityDisplayDayPeriod,
      activityDisplayWeekDay,
      activityDisplayDate,
      calendarActivityTypeShowTypes,
      setting12hTimeFormatTimeline,
      settingDisplayHourLines,
      settingDisplayTimeline;

  final int morningIntervalStart,
      forenoonIntervalStart,
      afternoonIntervalStart,
      eveningIntervalStart,
      nightIntervalStart,
      calendarDayColor;

  final String calendarActivityTypeLeft, calendarActivityTypeRight;

  MemoplannerSettings({
    this.displayAlarmButton = true,
    this.displayDeleteButton = true,
    this.displayEditButton = true,
    this.displayQuarterHour = true,
    this.displayTimeLeft = true,
    this.dayCaptionShowDayButtons = true,
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
    this.activityDisplayDate = true,
    this.calendarActivityTypeShowTypes = true,
    this.setting12hTimeFormatTimeline,
    this.settingDisplayHourLines = false,
    this.settingDisplayTimeline = true,
    this.morningIntervalStart = 21600000,
    this.forenoonIntervalStart = 36000000,
    this.afternoonIntervalStart = 43200000,
    this.eveningIntervalStart = 64800000,
    this.nightIntervalStart = 82800000,
    this.calendarActivityTypeLeft,
    this.calendarActivityTypeRight,
    this.calendarDayColor = 0,
  });

  factory MemoplannerSettings.fromSettingsList(
      List<MemoplannerSettingData> settings) {
    return _parseSettings(settings);
  }

  static MemoplannerSettings _parseSettings(
      List<MemoplannerSettingData> settings) {
    return MemoplannerSettings(
      displayAlarmButton: settings.getBool(
        displayAlarmButtonKey,
      ),
      displayDeleteButton: settings.getBool(
        displayDeleteButtonKey,
      ),
      displayEditButton: settings.getBool(
        displayEditButtonKey,
      ),
      displayQuarterHour: settings.getBool(
        displayQuarterHourKey,
      ),
      displayTimeLeft: settings.getBool(
        displayTimeLeftKey,
      ),
      dayCaptionShowDayButtons: settings.getBool(
        dayCaptionShowDayButtonsKey,
      ),
      activityDateEditable: settings.getBool(
        activityDateEditableKey,
      ),
      activityTypeEditable: settings.getBool(
        activityTypeEditableKey,
      ),
      activityEndTimeEditable: settings.getBool(
        activityEndTimeEditableKey,
      ),
      activityTimeBeforeCurrent: settings.getBool(
        activityTimeBeforeCurrentKey,
      ),
      activityRecurringEditable: settings.getBool(
        activityRecurringEditableKey,
      ),
      activityDisplayAlarmOption: settings.getBool(
        activityDisplayAlarmOptionKey,
      ),
      activityDisplaySilentAlarmOption: settings.getBool(
        activityDisplaySilentAlarmOptionKey,
      ),
      activityDisplayNoAlarmOption: settings.getBool(
        activityDisplayNoAlarmOptionKey,
      ),
      activityDisplayDayPeriod: settings.getBool(
        activityDisplayDayPeriodKey,
      ),
      activityDisplayWeekDay: settings.getBool(
        activityDisplayWeekDayKey,
      ),
      activityDisplayDate: settings.getBool(
        activityDisplayDateKey,
      ),
      calendarActivityTypeShowTypes: settings.getBool(
        calendarActivityTypeShowTypesKey,
      ),
      setting12hTimeFormatTimeline: settings.getBool(
        setting12hTimeFormatTimelineKey,
        defaultValue: null,
      ),
      settingDisplayHourLines: settings.getBool(
        settingDisplayHourLinesKey,
        defaultValue: false,
      ),
      settingDisplayTimeline: settings.getBool(
        settingDisplayTimelineKey,
      ),
      morningIntervalStart: settings.parse(
        morningIntervalStartKey,
        21600000,
      ),
      forenoonIntervalStart: settings.parse(
        forenoonIntervalStartKey,
        36000000,
      ),
      afternoonIntervalStart: settings.parse(
        afternoonIntervalStartKey,
        43200000,
      ),
      eveningIntervalStart: settings.parse(
        eveningIntervalStartKey,
        64800000,
      ),
      nightIntervalStart: settings.parse(
        nightIntervalStartKey,
        82800000,
      ),
      calendarActivityTypeLeft: settings.getString(
        calendarActivityTypeLeftKey,
      ),
      calendarActivityTypeRight: settings.getString(
        calendarActivityTypeRightKey,
      ),
      calendarDayColor: settings.parse(calendarDayColorKey, 0),
    );
  }
}

extension _Parsing on List<MemoplannerSettingData> {
  T parse<T>(String settingName, T defaultValue) {
    final setting =
        firstWhere((s) => s.identifier == settingName, orElse: () => null);
    if (setting == null) {
      return defaultValue;
    }
    return json.decode(setting.data);
  }

  String getString(
    String settingName, [
    String defaultValue,
  ]) =>
      firstWhere(
        (s) => s.identifier == settingName,
        orElse: () => null,
      )?.data ??
      defaultValue;

  bool getBool(
    String settingName, {
    bool defaultValue = true,
  }) {
    return parse<bool>(settingName, defaultValue);
  }
}

class DayParts {
  Duration get morning => Duration(milliseconds: morningStart);

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

class DayColors {
  static const int ALL_DAYS = 0, SATURDAY_AND_SUNDAY = 1, NO_COLORS = 2;
}

enum HourClockType { use12, use24, useSystem }
