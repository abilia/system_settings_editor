import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class DayCalendarViewSettings extends Equatable {
  static const String viewOptionsTimeIntervalKey = 'view_options_time_interval',
      viewOptionsTimepillarZoomKey = 'view_options_zoom',
      viewOptionsCalendarTypeKey = 'view_options_time_view',
      viewOptionsDotsKey = 'dots_in_timepillar';

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

  const DayCalendarViewSettings({
    this.display = const DayCalendarViewOptionsDisplaySettings(),
    this.dots = false,
    this.timepillarZoomIndex = 1,
    this.intervalTypeIndex = 1,
    this.calendarTypeIndex = 1,
  });

  DayCalendarViewSettings copyWith({
    DayCalendarViewOptionsDisplaySettings? display,
    bool? dots,
    DayCalendarType? calendarType,
    TimepillarIntervalType? intervalType,
    TimepillarZoom? timepillarZoom,
  }) =>
      DayCalendarViewSettings(
        display: display ?? this.display,
        dots: dots ?? this.dots,
        calendarTypeIndex: calendarType?.index ?? calendarTypeIndex,
        intervalTypeIndex: intervalType?.index ?? intervalTypeIndex,
        timepillarZoomIndex: timepillarZoom?.index ?? timepillarZoomIndex,
      );

  @override
  List<Object> get props => [
        display,
        dots,
        calendarTypeIndex,
        intervalTypeIndex,
        timepillarZoomIndex,
      ];
}
