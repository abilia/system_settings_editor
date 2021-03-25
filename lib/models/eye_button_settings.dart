import 'package:seagull/models/all.dart';

class EyeButtonSettings {
  final DayCalendarType calendarType;
  final bool dotsInTimepillar;
  final int zoom;
  final int dayInterval;

  EyeButtonSettings({
    this.calendarType,
    this.dotsInTimepillar,
    this.zoom,
    this.dayInterval,
  });
}
