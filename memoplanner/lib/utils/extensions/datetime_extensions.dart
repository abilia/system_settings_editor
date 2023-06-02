import 'package:memoplanner/models/all.dart';
import 'package:utils/date_time_extensions.dart';

extension DateTimeExtensionsModels on DateTime {
  DayPart dayPart(DayParts dayParts) {
    final timeAfterMidnight = difference(onlyDays());

    if (timeAfterMidnight >= dayParts.night) return DayPart.night;

    if (timeAfterMidnight >= dayParts.evening) return DayPart.evening;

    if (timeAfterMidnight >= dayParts.day) return DayPart.day;

    if (timeAfterMidnight >= dayParts.morning) return DayPart.morning;

    return DayPart.night;
  }

  bool isMidnight() => compareTo(onlyDays()) == 0;

  bool isNight(DayParts dayParts) {
    return DayPart.night == dayPart(dayParts);
  }

  bool isNightBeforeMidnight(DayParts dayParts) {
    final afterMidnight = difference(onlyDays());
    return afterMidnight >= dayParts.night;
  }
}
