import 'package:memoplanner/models/settings/day_calendar/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayCalendarViewDb {
  final SharedPreferences prefs;
  const DayCalendarViewDb(this.prefs);

  // TODO remove in 4.4
  bool get isNotSet =>
      !prefs.containsKey(
        DayCalendarViewOptionsDisplaySettings.displayCalendarTypeKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewOptionsDisplaySettings.displayIntervalTypeIntervalKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewOptionsDisplaySettings.displayTimepillarZoomKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewOptionsDisplaySettings.displayDurationKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewSettings.viewOptionsDotsKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewSettings.viewOptionsTimepillarZoomKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewSettings.viewOptionsTimeIntervalKey,
      ) ||
      !prefs.containsKey(
        DayCalendarViewSettings.viewOptionsCalendarTypeKey,
      );

  Future<void> setDayCalendarViewOptionsSettings(
    DayCalendarViewSettings dayCalendarViewOptionsSettings,
  ) async {
    await _setDayCalendarViewOptionsDisplaySettings(
      dayCalendarViewOptionsSettings.display,
    );
    await prefs.setBool(
      DayCalendarViewSettings.viewOptionsDotsKey,
      dayCalendarViewOptionsSettings.dots,
    );
    await prefs.setInt(
      DayCalendarViewSettings.viewOptionsTimepillarZoomKey,
      dayCalendarViewOptionsSettings.timepillarZoomIndex,
    );
    await prefs.setInt(
      DayCalendarViewSettings.viewOptionsTimeIntervalKey,
      dayCalendarViewOptionsSettings.intervalTypeIndex,
    );
    await prefs.setInt(
      DayCalendarViewSettings.viewOptionsCalendarTypeKey,
      dayCalendarViewOptionsSettings.calendarTypeIndex,
    );
  }

  Future<void> _setDayCalendarViewOptionsDisplaySettings(
    DayCalendarViewOptionsDisplaySettings dayCalendarViewOptionsSettings,
  ) async {
    await prefs.setBool(
      DayCalendarViewOptionsDisplaySettings.displayCalendarTypeKey,
      dayCalendarViewOptionsSettings.calendarType,
    );
    await prefs.setBool(
      DayCalendarViewOptionsDisplaySettings.displayIntervalTypeIntervalKey,
      dayCalendarViewOptionsSettings.intervalType,
    );
    await prefs.setBool(
      DayCalendarViewOptionsDisplaySettings.displayTimepillarZoomKey,
      dayCalendarViewOptionsSettings.timepillarZoom,
    );
    await prefs.setBool(
      DayCalendarViewOptionsDisplaySettings.displayDurationKey,
      dayCalendarViewOptionsSettings.duration,
    );
  }

  DayCalendarViewSettings get viewOptions {
    const defaults = DayCalendarViewSettings();
    return DayCalendarViewSettings(
      display: _dayCalendarViewOptionsDisplaySettings,
      dots: prefs.getBool(DayCalendarViewSettings.viewOptionsDotsKey) ??
          defaults.dots,
      timepillarZoomIndex:
          prefs.getInt(DayCalendarViewSettings.viewOptionsTimepillarZoomKey) ??
              defaults.timepillarZoomIndex,
      calendarTypeIndex:
          prefs.getInt(DayCalendarViewSettings.viewOptionsCalendarTypeKey) ??
              defaults.calendarTypeIndex,
      intervalTypeIndex:
          prefs.getInt(DayCalendarViewSettings.viewOptionsTimeIntervalKey) ??
              defaults.calendarTypeIndex,
    );
  }

  DayCalendarViewOptionsDisplaySettings
      get _dayCalendarViewOptionsDisplaySettings {
    const defaults = DayCalendarViewOptionsDisplaySettings();
    return DayCalendarViewOptionsDisplaySettings(
      calendarType: prefs.getBool(
              DayCalendarViewOptionsDisplaySettings.displayCalendarTypeKey) ??
          defaults.calendarType,
      intervalType: prefs.getBool(DayCalendarViewOptionsDisplaySettings
              .displayIntervalTypeIntervalKey) ??
          defaults.intervalType,
      timepillarZoom: prefs.getBool(
              DayCalendarViewOptionsDisplaySettings.displayTimepillarZoomKey) ??
          defaults.timepillarZoom,
      duration: prefs.getBool(
              DayCalendarViewOptionsDisplaySettings.displayDurationKey) ??
          defaults.duration,
    );
  }
}
