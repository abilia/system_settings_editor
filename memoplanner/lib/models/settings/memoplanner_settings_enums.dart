enum TimepillarIntervalType { interval, day, dayAndNight }

enum IntervalPart { day, night, dayAndNight }

enum DayColor { allDays, saturdayAndSunday, noColors }

enum StartView { dayCalendar, weekCalendar, monthCalendar, menu, photoAlbum }

enum ClockType { analogueDigital, analogue, digital }

enum AddActivityMode { editView, stepByStep }

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

enum TimepillarZoom { small, normal, large }

extension ZoomExtension on TimepillarZoom {
  double get zoomValue {
    switch (this) {
      case TimepillarZoom.small:
        return 0.75;
      case TimepillarZoom.normal:
        return 1;
      case TimepillarZoom.large:
        return 1.3;
      default:
        return 1;
    }
  }
}
