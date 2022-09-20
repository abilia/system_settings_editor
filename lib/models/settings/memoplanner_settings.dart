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
      activityDisplayDayPeriodKey = 'day_caption_show_period',
      activityDisplayWeekDayKey = 'day_caption_show_weekday',
      activityDisplayDateKey = 'day_caption_show_date',
      activityDisplayClockKey = 'day_caption_show_clock',
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
      calendarMonthViewShowColors;

  final AlarmSettings alarm;
  final CodeProtectSettings codeProtect;
  final KeepScreenAwakeSettings keepScreenAwake;
  final MenuSettings menu;
  final FunctionsSettings functions;
  final GeneralCalendarSettings calendar;
  final AddActivitySettings addActivity;
  final WeekCalendarSettings weekCalendar;

  const MemoplannerSettings({
    this.displayAlarmButton = true,
    this.displayDeleteButton = true,
    this.displayEditButton = true,
    this.displayQuarterHour = true,
    this.displayTimeLeft = true,
    this.dayCaptionShowDayButtons = true,
    this.activityDisplayDayPeriod = true,
    this.activityDisplayWeekDay = true,
    this.activityDisplayDate = true,
    this.activityDisplayClock = true,
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
    this.codeProtect = const CodeProtectSettings(),
    this.menu = const MenuSettings(),
    this.keepScreenAwake = const KeepScreenAwakeSettings(),
    this.functions = const FunctionsSettings(),
    this.calendar = const GeneralCalendarSettings(),
    this.addActivity = const AddActivitySettings(),
    this.weekCalendar = const WeekCalendarSettings(),
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
      codeProtect: CodeProtectSettings.fromSettingsMap(settings),
      menu: MenuSettings.fromSettingsMap(settings),
      keepScreenAwake: KeepScreenAwakeSettings.fromSettingsMap(settings),
      functions: FunctionsSettings.fromSettingsMap(settings),
      calendar: GeneralCalendarSettings.fromSettingsMap(settings),
      addActivity: AddActivitySettings.fromSettingsMap(settings),
      weekCalendar: WeekCalendarSettings.fromSettingsMap(settings),
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
        activityDisplayDayPeriod,
        activityDisplayWeekDay,
        activityDisplayDate,
        activityDisplayClock,
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
        codeProtect,
        menu,
        keepScreenAwake,
        functions,
        calendar,
        addActivity,
    weekCalendar,
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
