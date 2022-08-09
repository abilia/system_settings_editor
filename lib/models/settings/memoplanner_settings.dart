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
      viewOptionsTimeIntervalKey = 'view_options_time_interval',
      viewOptionsZoomKey = 'view_options_zoom',
      viewOptionsTimeViewKey = 'view_options_time_view',
      dotsInTimepillarKey = 'dots_in_timepillar',
      imageMenuDisplayPhotoItemKey = 'image_menu_display_photo_item',
      imageMenuDisplayCameraItemKey = 'image_menu_display_camera_item',
      imageMenuDisplayMyPhotosItemKey = 'image_menu_display_my_photos_item',
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
      dotsInTimepillar,
      imageMenuDisplayPhotoItem,
      imageMenuDisplayCameraItem,
      imageMenuDisplayMyPhotosItem,
      settingViewOptionsTimeView,
      settingViewOptionsTimeInterval,
      settingViewOptionsZoom,
      settingViewOptionsDurationDots;

  final int viewOptionsTimeInterval,
      viewOptionsTimeView,
      viewOptionsZoom,
      weekDisplayShowFullWeek,
      weekDisplayShowColorMode,
      calendarMonthViewShowColors,
      activityDefaultAlarmType;

  final AlarmSettings alarm;
  final StepByStepSettings stepByStep;
  final CodeProtectSettings codeProtect;
  final KeepScreenAwakeSettings keepScreenAwakeSettings;
  final MenuSettings menu;
  final EditActivitySettings editActivity;
  final AddActivitySettings addActivity;
  final FunctionSettings functions;
  final GeneralCalendarSettings calendar;

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
    this.dotsInTimepillar = false,
    this.imageMenuDisplayPhotoItem = true,
    this.imageMenuDisplayCameraItem = true,
    this.imageMenuDisplayMyPhotosItem = true,
    this.viewOptionsTimeInterval = 1,
    this.viewOptionsTimeView = 1,
    this.viewOptionsZoom = 1,
    this.alarm = const AlarmSettings(),
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
    this.functions = const FunctionSettings(),
    this.calendar = const GeneralCalendarSettings(),
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
      imageMenuDisplayPhotoItem: settings.getBool(
        imageMenuDisplayPhotoItemKey,
      ),
      imageMenuDisplayCameraItem: settings.getBool(
        imageMenuDisplayCameraItemKey,
      ),
      imageMenuDisplayMyPhotosItem: settings.getBool(
        imageMenuDisplayMyPhotosItemKey,
      ),
      viewOptionsTimeInterval: settings.parse(
        viewOptionsTimeIntervalKey,
        1,
      ),
      viewOptionsTimeView: settings.parse(
        viewOptionsTimeViewKey,
        DayCalendarType.oneTimepillar.index,
      ),
      dotsInTimepillar: settings.getBool(
        dotsInTimepillarKey,
        defaultValue: false,
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
      functions: FunctionSettings.fromSettingsMap(settings),
      calendar: GeneralCalendarSettings.fromSettingsMap(settings),
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
        viewOptionsTimeInterval,
        viewOptionsTimeView,
        dotsInTimepillar,
        viewOptionsZoom,
        alarm,
        imageMenuDisplayPhotoItem,
        imageMenuDisplayCameraItem,
        imageMenuDisplayMyPhotosItem,
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
        functions,
        calendar,
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
