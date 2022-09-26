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

  static const String monthCaptionShowMonthButtonsKey =
          'month_caption_show_month_buttons',
      monthCaptionShowYearKey = 'month_caption_show_year',
      monthCaptionShowClockKey = 'month_caption_show_clock',
      calendarMonthViewShowColorsKey = 'calendar_month_view_show_colors',
      viewOptionsTimeIntervalKey = 'view_options_time_interval',
      viewOptionsZoomKey = 'view_options_zoom',
      viewOptionsTimeViewKey = 'view_options_time_view',
      dotsInTimepillarKey = 'dots_in_timepillar',
      settingViewOptionsTimeViewKey = 'setting_view_options_time_view',
      settingViewOptionsTimeIntervalKey = 'setting_view_options_time_interval',
      settingViewOptionsZoomKey = 'setting_view_options_zoom',
      settingViewOptionsDurationDotsKey = 'setting_view_options_duration_dots';

  final bool monthCaptionShowMonthButtons,
      monthCaptionShowYear,
      monthCaptionShowClock,
      dotsInTimepillar,
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
  final ActivityViewSettings activityView;
  final AppBarSettings appBar;
  final PhotoMenuSettings photoMenu;

  const MemoplannerSettings({
    this.monthCaptionShowMonthButtons = true,
    this.monthCaptionShowYear = true,
    this.monthCaptionShowClock = true,
    this.calendarMonthViewShowColors = 1,
    this.dotsInTimepillar = false,
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
    this.activityView = const ActivityViewSettings(),
    this.appBar = const AppBarSettings(),
    this.photoMenu = const PhotoMenuSettings(),
  });

  factory MemoplannerSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    return MemoplannerSettings(
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
      activityView: ActivityViewSettings.fromSettingsMap(settings),
      appBar: AppBarSettings.fromSettingsMap(settings),
      photoMenu: PhotoMenuSettings.fromSettingsMap(settings),
    );
  }

  @override
  List<Object> get props => [
        monthCaptionShowMonthButtons,
        monthCaptionShowYear,
        monthCaptionShowClock,
        calendarMonthViewShowColors,
        viewOptionsTimeInterval,
        viewOptionsTimeView,
        dotsInTimepillar,
        viewOptionsZoom,
        alarm,
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
        activityView,
        appBar,
        photoMenu,
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
