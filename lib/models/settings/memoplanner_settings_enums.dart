enum TimepillarIntervalType { INTERVAL, DAY, DAY_AND_NIGHT }

enum IntervalPart { DAY, NIGHT, DAY_AND_NIGHT }

enum DayColor { allDays, saturdayAndSunday, noColors }

enum StartView { dayCalendar, weekCalendar, monthCalendar, menu, photoAlbum }

enum ClockType { analogueDigital, analogue, digital }

enum NewActivityMode { editView, stepByStep }

enum WeekDisplayDays { everyDay, weekdays }

extension WeekDisplayDaysExtension on WeekDisplayDays {
  int numberOfDays() {
    switch (this) {
      case WeekDisplayDays.everyDay:
        return 7;
      case WeekDisplayDays.weekdays:
        return 5;
      default:
        return 7;
    }
  }
}

enum WeekColor { captions, columns }

enum TimepillarZoom { SMALL, NORMAL, LARGE }

extension ZoomExtension on TimepillarZoom {
  double get zoomValue {
    switch (this) {
      case TimepillarZoom.SMALL:
        return 0.75;
      case TimepillarZoom.NORMAL:
        return 1;
      case TimepillarZoom.LARGE:
        return 1.3;
      default:
        return 1;
    }
  }
}
