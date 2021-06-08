import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class EyeButtonSettings {
  final DayCalendarType calendarType;
  final bool dotsInTimepillar;
  final TimepillarZoom timepillarZoom;
  final TimepillarIntervalType intervalType;

  EyeButtonSettings({
    required this.calendarType,
    required this.dotsInTimepillar,
    required this.timepillarZoom,
    required this.intervalType,
  });
}
