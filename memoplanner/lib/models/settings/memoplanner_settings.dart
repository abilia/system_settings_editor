import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class MemoplannerSettings extends Equatable {
  static const Set<String> noSyncSettings = {
    ...AlarmSettings.keys,
    ...KeepScreenAwakeSettings.keys,
    ...DayCalendarViewOptionsSettings.keys,
  };

  final AlarmSettings alarm;
  final CodeProtectSettings codeProtect;
  final KeepScreenAwakeSettings keepScreenAwake;
  final MenuSettings menu;
  final FunctionsSettings functions;
  final GeneralCalendarSettings calendar;
  final AddActivitySettings addActivity;
  final WeekCalendarSettings weekCalendar;
  final MonthCalendarSettings monthCalendar;
  final ActivityViewSettings activityView;
  final DayCalendarSettings dayCalendar;
  final PhotoMenuSettings photoMenu;

  bool get settingsInaccessible =>
      !functions.display.menu || !menu.showSettings;

  const MemoplannerSettings({
    this.alarm = const AlarmSettings(),
    this.codeProtect = const CodeProtectSettings(),
    this.menu = const MenuSettings(),
    this.keepScreenAwake = const KeepScreenAwakeSettings(),
    this.functions = const FunctionsSettings(),
    this.calendar = const GeneralCalendarSettings(),
    this.addActivity = const AddActivitySettings(),
    this.weekCalendar = const WeekCalendarSettings(),
    this.monthCalendar = const MonthCalendarSettings(),
    this.activityView = const ActivityViewSettings(),
    this.dayCalendar = const DayCalendarSettings(),
    this.photoMenu = const PhotoMenuSettings(),
  });

  factory MemoplannerSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    return MemoplannerSettings(
      alarm: AlarmSettings.fromSettingsMap(settings),
      codeProtect: CodeProtectSettings.fromSettingsMap(settings),
      menu: MenuSettings.fromSettingsMap(settings),
      keepScreenAwake: KeepScreenAwakeSettings.fromSettingsMap(settings),
      functions: FunctionsSettings.fromSettingsMap(settings),
      calendar: GeneralCalendarSettings.fromSettingsMap(settings),
      addActivity: AddActivitySettings.fromSettingsMap(settings),
      weekCalendar: WeekCalendarSettings.fromSettingsMap(settings),
      monthCalendar: MonthCalendarSettings.fromSettingsMap(settings),
      activityView: ActivityViewSettings.fromSettingsMap(settings),
      dayCalendar: DayCalendarSettings.fromSettingsMap(settings),
      photoMenu: PhotoMenuSettings.fromSettingsMap(settings),
    );
  }

  @override
  List<Object> get props => [
        alarm,
        codeProtect,
        menu,
        keepScreenAwake,
        functions,
        calendar,
        addActivity,
        weekCalendar,
        monthCalendar,
        activityView,
        dayCalendar,
        photoMenu,
      ];
}

class MemoplannerSettingsLoaded extends MemoplannerSettings {
  MemoplannerSettingsLoaded(MemoplannerSettings settings)
      : super(
          alarm: settings.alarm,
          codeProtect: settings.codeProtect,
          menu: settings.menu,
          keepScreenAwake: settings.keepScreenAwake,
          functions: settings.functions,
          calendar: settings.calendar,
          addActivity: settings.addActivity,
          weekCalendar: settings.weekCalendar,
          monthCalendar: settings.monthCalendar,
          activityView: settings.activityView,
          dayCalendar: settings.dayCalendar,
          photoMenu: settings.photoMenu,
        );
}

class MemoplannerSettingsNotLoaded extends MemoplannerSettings {
  const MemoplannerSettingsNotLoaded() : super();
}

class MemoplannerSettingsFailed extends MemoplannerSettings {
  const MemoplannerSettingsFailed() : super();
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
