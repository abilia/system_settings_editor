import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class DayCalendarViewOptionsSettings extends Equatable {
  static const String viewOptionsTimeIntervalKey = 'view_options_time_interval',
      viewOptionsTimepillarZoomKey = 'view_options_zoom',
      viewOptionsCalendarTypeKey = 'view_options_time_view',
      viewOptionsDotsKey = 'dots_in_timepillar';

  static const List<String> keys = [
    viewOptionsTimepillarZoomKey,
    viewOptionsTimeIntervalKey,
    viewOptionsCalendarTypeKey,
    viewOptionsDotsKey
  ];

  final DayCalendarViewOptionsDisplaySettings display;

  final bool dots;

  final int timepillarZoomIndex, intervalTypeIndex, calendarTypeIndex;

  TimepillarZoom get timepillarZoom =>
      TimepillarZoom.values[timepillarZoomIndex];

  TimepillarIntervalType get intervalType =>
      TimepillarIntervalType.values[intervalTypeIndex];

  DayCalendarType get calendarType => DayCalendarType.values[calendarTypeIndex];

  bool get displayEyeButton =>
      display.calendarType ||
      (calendarType == DayCalendarType.oneTimepillar &&
          (display.intervalType || display.timepillarZoom || display.duration));

  const DayCalendarViewOptionsSettings({
    this.display = const DayCalendarViewOptionsDisplaySettings(),
    this.dots = false,
    this.timepillarZoomIndex = 1,
    this.intervalTypeIndex = 1,
    this.calendarTypeIndex = 1,
  });

  factory DayCalendarViewOptionsSettings.fromSettingsMap(
      Map<String, MemoplannerSettingData> settings) {
    return DayCalendarViewOptionsSettings(
      display: DayCalendarViewOptionsDisplaySettings.fromSettingsMap(settings),
      dots: settings.parse(viewOptionsDotsKey, false),
      timepillarZoomIndex: settings.parse(
        viewOptionsTimepillarZoomKey,
        1,
      ),
      intervalTypeIndex: settings.parse(
        viewOptionsTimeIntervalKey,
        1,
      ),
      calendarTypeIndex: settings.parse(
        viewOptionsCalendarTypeKey,
        1,
      ),
    );
  }

  DayCalendarViewOptionsSettings copyWith({
    DayCalendarViewOptionsDisplaySettings? display,
    bool? dots,
    DayCalendarType? calendarType,
    TimepillarIntervalType? intervalType,
    TimepillarZoom? timepillarZoom,
  }) =>
      DayCalendarViewOptionsSettings(
        display: display ?? this.display,
        dots: dots ?? this.dots,
        calendarTypeIndex: calendarType?.index ?? calendarTypeIndex,
        intervalTypeIndex: intervalType?.index ?? intervalTypeIndex,
        timepillarZoomIndex: timepillarZoom?.index ?? timepillarZoomIndex,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        ...display.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: dots,
          identifier: viewOptionsDotsKey,
        ),
        MemoplannerSettingData.fromData(
          data: calendarTypeIndex,
          identifier: viewOptionsCalendarTypeKey,
        ),
        MemoplannerSettingData.fromData(
          data: intervalTypeIndex,
          identifier: viewOptionsTimeIntervalKey,
        ),
        MemoplannerSettingData.fromData(
          data: timepillarZoomIndex,
          identifier: viewOptionsTimepillarZoomKey,
        ),
      ];

  @override
  List<Object> get props => [
        display,
        dots,
        calendarTypeIndex,
        intervalTypeIndex,
        timepillarZoomIndex,
      ];
}
