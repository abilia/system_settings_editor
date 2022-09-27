import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class MemoplannerSettings extends Equatable {
  static const Set<String> noSyncSettings = {
    ...AlarmSettings.keys,
    ...KeepScreenAwakeSettings.keys,
    ...DayCalendarViewOptionsSettings.keys,
  };

  static const String monthCaptionShowMonthButtonsKey =
          'month_caption_show_month_buttons',
      monthCaptionShowYearKey = 'month_caption_show_year',
      monthCaptionShowClockKey = 'month_caption_show_clock',
      calendarMonthViewShowColorsKey = 'calendar_month_view_show_colors';

  final bool monthCaptionShowMonthButtons,
      monthCaptionShowYear,
      monthCaptionShowClock;

  final int calendarMonthViewShowColors;

  final AlarmSettings alarm;
  final CodeProtectSettings codeProtect;
  final KeepScreenAwakeSettings keepScreenAwake;
  final MenuSettings menu;
  final FunctionsSettings functions;
  final GeneralCalendarSettings calendar;
  final AddActivitySettings addActivity;
  final WeekCalendarSettings weekCalendar;
  final ActivityViewSettings activityView;
  final DayCalendarSettings dayCalendar;
  final PhotoMenuSettings photoMenu;

  const MemoplannerSettings({
    this.monthCaptionShowMonthButtons = true,
    this.monthCaptionShowYear = true,
    this.monthCaptionShowClock = true,
    this.calendarMonthViewShowColors = 1,
    this.alarm = const AlarmSettings(),
    this.codeProtect = const CodeProtectSettings(),
    this.menu = const MenuSettings(),
    this.keepScreenAwake = const KeepScreenAwakeSettings(),
    this.functions = const FunctionsSettings(),
    this.calendar = const GeneralCalendarSettings(),
    this.addActivity = const AddActivitySettings(),
    this.weekCalendar = const WeekCalendarSettings(),
    this.activityView = const ActivityViewSettings(),
    this.dayCalendar = const DayCalendarSettings(),
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
      alarm: AlarmSettings.fromSettingsMap(settings),
      codeProtect: CodeProtectSettings.fromSettingsMap(settings),
      menu: MenuSettings.fromSettingsMap(settings),
      keepScreenAwake: KeepScreenAwakeSettings.fromSettingsMap(settings),
      functions: FunctionsSettings.fromSettingsMap(settings),
      calendar: GeneralCalendarSettings.fromSettingsMap(settings),
      addActivity: AddActivitySettings.fromSettingsMap(settings),
      weekCalendar: WeekCalendarSettings.fromSettingsMap(settings),
      activityView: ActivityViewSettings.fromSettingsMap(settings),
      dayCalendar: DayCalendarSettings.fromSettingsMap(settings),
      photoMenu: PhotoMenuSettings.fromSettingsMap(settings),
    );
  }

  @override
  List<Object> get props => [
        monthCaptionShowMonthButtons,
        monthCaptionShowYear,
        monthCaptionShowClock,
        calendarMonthViewShowColors,
        alarm,
        codeProtect,
        menu,
        keepScreenAwake,
        functions,
        calendar,
        addActivity,
        weekCalendar,
        activityView,
        dayCalendar,
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
