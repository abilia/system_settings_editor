import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class MemoplannerSettings extends Equatable {
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
      settingDisplayTimelineKey = 'setting_display_line_timeline',
      viewOptionsTimeIntervalKey = 'view_options_time_interval',
      viewOptionsZoomKey = 'view_options_zoom',
      nonCheckableActivityAlarmKey = 'activity_alarm_without_confirm',
      checkableActivityAlarmKey = 'activity_alarm_with_confirm',
      reminderAlarmKey = 'activity_reminder_alarm',
      vibrateAtReminderKey = 'setting_vibrate_at_reminder',
      alarmDurationKey = 'alarm_duration',
      functionMenuDisplayWeekKey = 'function_menu_display_week',
      functionMenuDisplayMonthKey = 'function_menu_display_month',
      functionMenuDisplayNewActivityKey = 'function_menu_display_new_activity',
      functionMenuDisplayMenuKey = 'function_menu_display_menu',
      activityTimeoutKey = 'activity_timeout',
      useScreensaverKey = 'use_screensaver',
      functionMenuStartViewKey = 'function_menu_start_view',
      imageMenuDisplayPhotoItemKey = 'image_menu_display_photo_item',
      imageMenuDisplayCameraItemKey = 'image_menu_display_camera_item';

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
      settingDisplayTimeline,
      vibrateAtReminder,
      functionMenuDisplayWeek,
      functionMenuDisplayMonth,
      functionMenuDisplayNewActivity,
      functionMenuDisplayMenu,
      useScreensaver,
      imageMenuDisplayPhotoItem,
      imageMenuDisplayCameraItem;

  final int morningIntervalStart,
      forenoonIntervalStart,
      afternoonIntervalStart,
      eveningIntervalStart,
      nightIntervalStart,
      calendarDayColor,
      viewOptionsTimeInterval,
      viewOptionsZoom,
      alarmDuration,
      activityTimeout,
      functionMenuStartView;

  final String calendarActivityTypeLeft,
      calendarActivityTypeRight,
      nonCheckableActivityAlarm,
      checkableActivityAlarm,
      reminderAlarm;

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
    this.imageMenuDisplayPhotoItem = true,
    this.imageMenuDisplayCameraItem = true,
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
    this.viewOptionsTimeInterval = 1,
    this.viewOptionsZoom = 1,
    this.alarmDuration = 30000,
    this.checkableActivityAlarm,
    this.nonCheckableActivityAlarm,
    this.reminderAlarm,
    this.vibrateAtReminder = true,
    this.functionMenuDisplayWeek = true,
    this.functionMenuDisplayMonth = true,
    this.functionMenuDisplayNewActivity = true,
    this.functionMenuDisplayMenu = true,
    this.activityTimeout = 0,
    this.useScreensaver = false,
    this.functionMenuStartView = 0,
  });

  factory MemoplannerSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
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
      functionMenuDisplayWeek: settings.getBool(
        functionMenuDisplayWeekKey,
      ),
      functionMenuDisplayMonth: settings.getBool(
        functionMenuDisplayMonthKey,
      ),
      functionMenuDisplayNewActivity: settings.getBool(
        functionMenuDisplayNewActivityKey,
      ),
      functionMenuDisplayMenu: settings.getBool(
        functionMenuDisplayMenuKey,
      ),
      useScreensaver: settings.getBool(
        useScreensaverKey,
        defaultValue: false,
      ),
      imageMenuDisplayPhotoItem: settings.getBool(
        imageMenuDisplayPhotoItemKey,
      ),
      imageMenuDisplayCameraItem: settings.getBool(
        imageMenuDisplayCameraItemKey,
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
      activityTimeout: settings.parse(
        activityTimeoutKey,
        0,
      ),
      functionMenuStartView: settings.parse(
        functionMenuStartViewKey,
        0,
      ),
      calendarActivityTypeLeft: settings.parse<String>(
        calendarActivityTypeLeftKey,
      ),
      calendarActivityTypeRight: settings.parse<String>(
        calendarActivityTypeRightKey,
      ),
      calendarDayColor: settings.parse(calendarDayColorKey, 0),
      viewOptionsTimeInterval: settings.parse(viewOptionsTimeIntervalKey, 1),
      viewOptionsZoom: settings.parse(viewOptionsZoomKey, 1),
      alarmDuration: settings.parse(alarmDurationKey, 30000),
      checkableActivityAlarm:
          settings.parse(checkableActivityAlarmKey, Sound.Default.name()),
      nonCheckableActivityAlarm:
          settings.parse(nonCheckableActivityAlarmKey, Sound.Default.name()),
      reminderAlarm: settings.parse(reminderAlarmKey, Sound.Default.name()),
      vibrateAtReminder:
          settings.getBool(vibrateAtReminderKey, defaultValue: true),
    );
  }

  @override
  List<Object> get props => [
        displayAlarmButton,
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
        settingDisplayTimeline,
        morningIntervalStart,
        forenoonIntervalStart,
        afternoonIntervalStart,
        eveningIntervalStart,
        nightIntervalStart,
        calendarActivityTypeLeft,
        calendarActivityTypeRight,
        calendarDayColor,
        viewOptionsTimeInterval,
        viewOptionsZoom,
        alarmDuration,
        checkableActivityAlarm,
        nonCheckableActivityAlarm,
        reminderAlarm,
        vibrateAtReminder,
        functionMenuDisplayWeek,
        functionMenuDisplayMonth,
        functionMenuDisplayNewActivity,
        functionMenuDisplayMenu,
        activityTimeout,
        useScreensaver,
        functionMenuStartView,
        imageMenuDisplayPhotoItem,
        imageMenuDisplayCameraItem
      ];
}

extension _Parsing on Map<String, MemoplannerSettingData> {
  T parse<T>(String settingName, [T defaultValue]) {
    try {
      return this[GenericData.uniqueId(
                  GenericType.memoPlannerSettings, settingName)]
              ?.data ??
          defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  bool getBool(
    String settingName, {
    bool defaultValue = true,
  }) =>
      parse<bool>(settingName, defaultValue);
}

class DayParts {
  Duration get morning => Duration(milliseconds: morningStart);
  Duration get night => Duration(milliseconds: nightStart);

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

enum DayColor { allDays, saturdayAndSunday, noColors }

enum HourClockType { use12, use24, useSystem }

enum StartView { dayCalendar, weekCalendar, monthCalendar, menu, photoAlbum }
