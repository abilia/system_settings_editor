import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class DayCalendarViewOptionsDisplaySettings extends Equatable {
  static const String displayCalendarTypeKey = 'setting_view_options_time_view',
      displayIntervalTypeIntervalKey = 'setting_view_options_time_interval',
      displayTimepillarZoomKey = 'setting_view_options_zoom',
      displayDurationKey = 'setting_view_options_duration_dots';

  final bool calendarType, intervalType, timepillarZoom, duration;

  const DayCalendarViewOptionsDisplaySettings({
    this.calendarType = true,
    this.intervalType = true,
    this.timepillarZoom = true,
    this.duration = true,
  });

  factory DayCalendarViewOptionsDisplaySettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    return DayCalendarViewOptionsDisplaySettings(
      calendarType: settings.parse(displayCalendarTypeKey, true),
      intervalType: settings.parse(displayIntervalTypeIntervalKey, true),
      timepillarZoom: settings.parse(displayTimepillarZoomKey, true),
      duration: settings.parse(displayDurationKey, true),
    );
  }

  DayCalendarViewOptionsDisplaySettings copyWith({
    bool? calendarType,
    bool? intervalType,
    bool? timepillarZoom,
    bool? duration,
  }) =>
      DayCalendarViewOptionsDisplaySettings(
        calendarType: calendarType ?? this.calendarType,
        intervalType: intervalType ?? this.intervalType,
        timepillarZoom: timepillarZoom ?? this.timepillarZoom,
        duration: duration ?? this.duration,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: calendarType,
          identifier: displayCalendarTypeKey,
        ),
        MemoplannerSettingData.fromData(
          data: intervalType,
          identifier: displayIntervalTypeIntervalKey,
        ),
        MemoplannerSettingData.fromData(
          data: timepillarZoom,
          identifier: displayTimepillarZoomKey,
        ),
        MemoplannerSettingData.fromData(
          data: duration,
          identifier: displayDurationKey,
        ),
      ];

  @override
  List<Object> get props => [
        calendarType,
        intervalType,
        timepillarZoom,
        duration,
      ];
}
