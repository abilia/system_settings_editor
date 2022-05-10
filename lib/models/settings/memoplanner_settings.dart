import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class MemoplannerSettings extends Equatable {
  static const Set<String> noSyncSettings = {
    ...AlarmSettings.keys,
    ...KeepScreenAwakeSettings.keys,
    // eye button settings
    viewOptionsZoomKey,
    viewOptionsTimeIntervalKey,
    viewOptionsTimeViewKey,
    dotsInTimepillarKey,
  };

  static const String displayAlarmButtonKey =
          'activity_detailed_setting_display_change_alarm_button',
      displayDeleteButtonKey =
          'activity_detailed_setting_display_delete_button',
      displayEditButtonKey = 'activity_detailed_setting_display_edit_button',
      displayQuarterHourKey = 'activity_detailed_setting_display_qhw',
      displayTimeLeftKey = 'activity_detailed_setting_display_qhw_time_left',
      dayCaptionShowDayButtonsKey = 'day_caption_show_day_buttons',
      activityDefaultAlarmTypeKey = 'activity_default_alarm_type',
      activityDisplayDayPeriodKey = 'day_caption_show_period',
      activityDisplayWeekDayKey = 'day_caption_show_weekday',
      activityDisplayDateKey = 'day_caption_show_date',
      activityDisplayClockKey = 'day_caption_show_clock',
      addActivityTypeAdvancedKey = 'add_activity_type_advanced',
      weekCaptionShowBrowseButtonsKey = 'week_caption_show_week_buttons',
      weekCaptionShowWeekNumberKey = 'week_caption_show_week_number',
      weekCaptionShowYearKey = 'week_caption_show_year',
      weekCaptionShowClockKey = 'week_caption_show_clock',
      weekDisplayShowFullWeekKey = 'week_display_show_full_week',
      weekDisplayShowColorModeKey = 'week_display_show_color_mode',
      monthCaptionShowMonthButtonsKey = 'month_caption_show_month_buttons',
      monthCaptionShowYearKey = 'month_caption_show_year',
      monthCaptionShowClockKey = 'month_caption_show_clock',
      calendarMonthViewShowColorsKey = 'calendar_month_view_show_colors',
      morningIntervalStartKey = 'morning_interval_start',
      forenoonIntervalStartKey = 'forenoon_interval_start',
      eveningIntervalStartKey = 'evening_interval_start',
      nightIntervalStartKey = 'night_interval_start',
      calendarActivityTypeLeftKey = 'calendar_activity_type_left',
      calendarActivityTypeRightKey = 'calendar_activity_type_right',
      calendarActivityTypeLeftImageKey = 'calendar_activity_type_image_left',
      calendarActivityTypeRightImageKey = 'calendar_activity_type_image_right',
      calendarActivityTypeShowTypesKey = 'calendar_activity_type_show_types',
      calendarActivityTypeShowColorKey = 'calendar_activity_type_show_color',
      calendarDayColorKey = 'calendar_daycolor',
      setting12hTimeFormatTimelineKey = 'setting_12h_time_format_timeline',
      settingDisplayHourLinesKey = 'setting_display_hour_lines',
      settingDisplayTimelineKey = 'setting_display_line_timeline',
      viewOptionsTimeIntervalKey = 'view_options_time_interval',
      viewOptionsZoomKey = 'view_options_zoom',
      viewOptionsTimeViewKey = 'view_options_time_view',
      dotsInTimepillarKey = 'dots_in_timepillar',
      functionMenuDisplayWeekKey = 'function_menu_display_week',
      functionMenuDisplayMonthKey = 'function_menu_display_month',
      functionMenuDisplayNewActivityKey = 'function_menu_display_new_activity',
      functionMenuDisplayNewTimerKey = 'function_menu_display_new_timer',
      functionMenuDisplayMenuKey = 'function_menu_display_menu',
      activityTimeoutKey = 'activity_timeout',
      useScreensaverKey = 'use_screensaver',
      functionMenuStartViewKey = 'function_menu_start_view',
      imageMenuDisplayPhotoItemKey = 'image_menu_display_photo_item',
      imageMenuDisplayCameraItemKey = 'image_menu_display_camera_item',
      imageMenuDisplayMyPhotosItemKey = 'image_menu_display_my_photos_item',
      settingClockTypeKey = 'setting_clock_type',
      settingTimePillarTimelineKey = 'setting_time_pillar_timeline',
      settingViewOptionsTimeViewKey = 'setting_view_options_time_view',
      settingViewOptionsTimeIntervalKey = 'setting_view_options_time_interval',
      settingViewOptionsZoomKey = 'setting_view_options_zoom',
      settingViewOptionsDurationDotsKey = 'setting_view_options_duration_dots';

  final bool displayAlarmButton,
      displayDeleteButton,
      displayEditButton,
      displayQuarterHour,
      displayTimeLeft,
      dayCaptionShowDayButtons,
      activityDisplayDayPeriod,
      activityDisplayWeekDay,
      activityDisplayDate,
      activityDisplayClock,
      addActivityTypeAdvanced,
      weekCaptionShowBrowseButtons,
      weekCaptionShowWeekNumber,
      weekCaptionShowYear,
      weekCaptionShowClock,
      monthCaptionShowMonthButtons,
      monthCaptionShowYear,
      monthCaptionShowClock,
      calendarActivityTypeShowTypes,
      calendarActivityTypeShowColor,
      setting12hTimeFormatTimeline,
      settingDisplayHourLines,
      settingDisplayTimeline,
      dotsInTimepillar,
      functionMenuDisplayWeek,
      functionMenuDisplayMonth,
      functionMenuDisplayNewActivity,
      functionMenuDisplayNewTimer,
      functionMenuDisplayMenu,
      useScreensaver,
      imageMenuDisplayPhotoItem,
      imageMenuDisplayCameraItem,
      imageMenuDisplayMyPhotosItem,
      settingTimePillarTimeline,
      settingViewOptionsTimeView,
      settingViewOptionsTimeInterval,
      settingViewOptionsZoom,
      settingViewOptionsDurationDots;

  final int morningIntervalStart,
      dayIntervalStart,
      eveningIntervalStart,
      nightIntervalStart,
      calendarDayColor,
      viewOptionsTimeInterval,
      viewOptionsTimeView,
      viewOptionsZoom,
      weekDisplayShowFullWeek,
      weekDisplayShowColorMode,
      calendarMonthViewShowColors,
      activityTimeout,
      functionMenuStartView,
      settingClockType,
      activityDefaultAlarmType;

  final String calendarActivityTypeLeft,
      calendarActivityTypeRight,
      calendarActivityTypeLeftImage,
      calendarActivityTypeRightImage;

  final AlarmSettings alarm;
  final StepByStepSettings stepByStep;
  final CodeProtectSettings codeProtect;
  final KeepScreenAwakeSettings keepScreenAwakeSettings;
  final MenuSettings menu;
  final EditActivitySettings editActivity;
  final AddActivitySettings addActivity;

  const MemoplannerSettings({
    this.displayAlarmButton = true,
    this.displayDeleteButton = true,
    this.displayEditButton = true,
    this.displayQuarterHour = true,
    this.displayTimeLeft = true,
    this.dayCaptionShowDayButtons = true,
    this.activityDefaultAlarmType = alarmSoundAndVibration,
    this.activityDisplayDayPeriod = true,
    this.activityDisplayWeekDay = true,
    this.activityDisplayDate = true,
    this.activityDisplayClock = true,
    this.addActivityTypeAdvanced = true,
    this.weekCaptionShowBrowseButtons = true,
    this.weekCaptionShowWeekNumber = true,
    this.weekCaptionShowYear = true,
    this.weekCaptionShowClock = true,
    this.weekDisplayShowFullWeek = 0,
    this.weekDisplayShowColorMode = 1,
    this.monthCaptionShowMonthButtons = true,
    this.monthCaptionShowYear = true,
    this.monthCaptionShowClock = true,
    this.calendarMonthViewShowColors = 1,
    this.dotsInTimepillar = true,
    this.imageMenuDisplayPhotoItem = true,
    this.imageMenuDisplayCameraItem = true,
    this.imageMenuDisplayMyPhotosItem = true,
    this.setting12hTimeFormatTimeline = false,
    this.settingDisplayHourLines = false,
    this.settingDisplayTimeline = true,
    this.morningIntervalStart = DayParts.morningDefault,
    this.dayIntervalStart = DayParts.dayDefault,
    this.eveningIntervalStart = DayParts.eveningDefault,
    this.nightIntervalStart = DayParts.nightDefault,
    this.calendarActivityTypeLeft = '',
    this.calendarActivityTypeRight = '',
    this.calendarActivityTypeLeftImage = '',
    this.calendarActivityTypeRightImage = '',
    this.calendarActivityTypeShowTypes = true,
    this.calendarActivityTypeShowColor = true,
    this.calendarDayColor = 0,
    this.viewOptionsTimeInterval = 1,
    this.viewOptionsTimeView = 0,
    this.viewOptionsZoom = 1,
    this.alarm = const AlarmSettings(),
    this.functionMenuDisplayWeek = true,
    this.functionMenuDisplayMonth = true,
    this.functionMenuDisplayNewActivity = true,
    this.functionMenuDisplayNewTimer = true,
    this.functionMenuDisplayMenu = true,
    this.activityTimeout = 0,
    this.useScreensaver = false,
    this.functionMenuStartView = 0,
    this.settingClockType = 0,
    this.settingTimePillarTimeline = false,
    this.settingViewOptionsTimeView = true,
    this.settingViewOptionsTimeInterval = true,
    this.settingViewOptionsZoom = true,
    this.settingViewOptionsDurationDots = true,
    this.stepByStep = const StepByStepSettings(),
    this.codeProtect = const CodeProtectSettings(),
    this.menu = const MenuSettings(),
    this.keepScreenAwakeSettings = const KeepScreenAwakeSettings(),
    this.editActivity = const EditActivitySettings(),
    this.addActivity = const AddActivitySettings(),
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
      activityDefaultAlarmType: settings.parse(
        activityDefaultAlarmTypeKey,
        alarmSoundAndVibration,
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
      activityDisplayClock: settings.getBool(
        activityDisplayClockKey,
      ),
      addActivityTypeAdvanced: settings.getBool(
        addActivityTypeAdvancedKey,
      ),
      weekCaptionShowBrowseButtons: settings.getBool(
        weekCaptionShowBrowseButtonsKey,
      ),
      weekCaptionShowWeekNumber: settings.getBool(
        weekCaptionShowWeekNumberKey,
      ),
      weekCaptionShowYear: settings.getBool(
        weekCaptionShowYearKey,
      ),
      weekCaptionShowClock: settings.getBool(
        weekCaptionShowClockKey,
      ),
      weekDisplayShowFullWeek: settings.parse(
        weekDisplayShowFullWeekKey,
        WeekDisplayDays.everyDay.index,
      ),
      weekDisplayShowColorMode: settings.parse(
        weekDisplayShowColorModeKey,
        WeekColor.columns.index,
      ),
      monthCaptionShowMonthButtons: settings.getBool(
        monthCaptionShowMonthButtonsKey,
      ),
      monthCaptionShowYear: settings.getBool(
        monthCaptionShowYearKey,
      ),
      monthCaptionShowClock: settings.getBool(
        monthCaptionShowClockKey,
      ),
      calendarMonthViewShowColors: settings.parse(
        calendarMonthViewShowColorsKey,
        WeekColor.columns.index,
      ),
      calendarActivityTypeShowTypes: settings.getBool(
        calendarActivityTypeShowTypesKey,
      ),
      calendarActivityTypeShowColor: settings.getBool(
        calendarActivityTypeShowColorKey,
      ),
      setting12hTimeFormatTimeline: settings.getBool(
        setting12hTimeFormatTimelineKey,
        defaultValue: false,
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
      functionMenuDisplayNewTimer: settings.getBool(
        functionMenuDisplayNewTimerKey,
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
      imageMenuDisplayMyPhotosItem: settings.getBool(
        imageMenuDisplayMyPhotosItemKey,
      ),
      settingTimePillarTimeline: settings.getBool(
        settingTimePillarTimelineKey,
        defaultValue: false,
      ),
      morningIntervalStart: settings.parse(
        morningIntervalStartKey,
        DayParts.morningDefault,
      ),
      dayIntervalStart: settings.parse(
        forenoonIntervalStartKey,
        DayParts.dayDefault,
      ),
      eveningIntervalStart: settings.parse(
        eveningIntervalStartKey,
        DayParts.eveningDefault,
      ),
      nightIntervalStart: settings.parse(
        nightIntervalStartKey,
        DayParts.nightDefault,
      ),
      activityTimeout: settings.parse(
        activityTimeoutKey,
        0,
      ),
      functionMenuStartView: settings.parse(
        functionMenuStartViewKey,
        0,
      ),
      settingClockType: settings.parse(
        settingClockTypeKey,
        0,
      ),
      calendarActivityTypeLeft: settings.parse<String>(
        calendarActivityTypeLeftKey,
        '',
      ),
      calendarActivityTypeRight: settings.parse<String>(
        calendarActivityTypeRightKey,
        '',
      ),
      calendarActivityTypeLeftImage: settings.parse<String>(
        calendarActivityTypeLeftImageKey,
        '',
      ),
      calendarActivityTypeRightImage: settings.parse<String>(
        calendarActivityTypeRightImageKey,
        '',
      ),
      calendarDayColor: settings.parse(
        calendarDayColorKey,
        0,
      ),
      viewOptionsTimeInterval: settings.parse(
        viewOptionsTimeIntervalKey,
        1,
      ),
      viewOptionsTimeView: settings.parse(
        viewOptionsTimeViewKey,
        DayCalendarType.list.index,
      ),
      dotsInTimepillar: settings.getBool(
        dotsInTimepillarKey,
        defaultValue: true,
      ),
      viewOptionsZoom: settings.parse(
        viewOptionsZoomKey,
        1,
      ),
      alarm: AlarmSettings.fromSettingsMap(settings),
      settingViewOptionsTimeView: settings.getBool(
        settingViewOptionsTimeViewKey,
      ),
      settingViewOptionsTimeInterval: settings.getBool(
        settingViewOptionsTimeIntervalKey,
      ),
      settingViewOptionsZoom: settings.getBool(
        settingViewOptionsZoomKey,
      ),
      settingViewOptionsDurationDots: settings.getBool(
        settingViewOptionsDurationDotsKey,
      ),
      stepByStep: StepByStepSettings.fromSettingsMap(settings),
      codeProtect: CodeProtectSettings.fromSettingsMap(settings),
      menu: MenuSettings.fromSettingsMap(settings),
      keepScreenAwakeSettings:
          KeepScreenAwakeSettings.fromSettingsMap(settings),
      editActivity: EditActivitySettings.fromSettingsMap(settings),
      addActivity: AddActivitySettings.fromSettingsMap(settings),
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
        activityDefaultAlarmType,
        activityDisplayDayPeriod,
        activityDisplayWeekDay,
        activityDisplayDate,
        activityDisplayClock,
        addActivityTypeAdvanced,
        weekCaptionShowBrowseButtons,
        weekCaptionShowWeekNumber,
        weekCaptionShowYear,
        weekCaptionShowClock,
        weekDisplayShowFullWeek,
        weekDisplayShowColorMode,
        monthCaptionShowMonthButtons,
        monthCaptionShowYear,
        monthCaptionShowClock,
        calendarMonthViewShowColors,
        setting12hTimeFormatTimeline,
        settingDisplayHourLines,
        settingDisplayTimeline,
        morningIntervalStart,
        dayIntervalStart,
        eveningIntervalStart,
        nightIntervalStart,
        calendarActivityTypeLeft,
        calendarActivityTypeRight,
        calendarActivityTypeLeftImage,
        calendarActivityTypeRightImage,
        calendarActivityTypeShowTypes,
        calendarActivityTypeShowColor,
        calendarDayColor,
        viewOptionsTimeInterval,
        viewOptionsTimeView,
        dotsInTimepillar,
        viewOptionsZoom,
        alarm,
        functionMenuDisplayWeek,
        functionMenuDisplayMonth,
        functionMenuDisplayNewActivity,
        functionMenuDisplayNewTimer,
        functionMenuDisplayMenu,
        activityTimeout,
        useScreensaver,
        functionMenuStartView,
        imageMenuDisplayPhotoItem,
        imageMenuDisplayCameraItem,
        imageMenuDisplayMyPhotosItem,
        settingClockType,
        settingTimePillarTimeline,
        settingViewOptionsTimeView,
        settingViewOptionsTimeInterval,
        settingViewOptionsZoom,
        settingViewOptionsDurationDots,
        stepByStep,
        codeProtect,
        menu,
        keepScreenAwakeSettings,
        editActivity,
        addActivity,
      ];
}

extension Parsing on Map<String, MemoplannerSettingData> {
  T parse<T>(String settingName, T defaultValue) {
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
