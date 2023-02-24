import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/models/all.dart';
import 'package:utils/date_time_extensions.dart';

final yMd = DateFormat('y-MM-dd').format;
final hm = DateFormat.Hm().format;

extension DateTimeExtensionsModels on DateTime {
  Occasion occasion(DateTime now) => isAfter(now)
      ? Occasion.future
      : isBefore(now)
          ? Occasion.past
          : Occasion.current;

  Occasion dayOccasion(DateTime now) => isAtSameDay(now)
      ? Occasion.current
      : isAfter(now)
          ? Occasion.future
          : Occasion.past;

  DateTime withTime(TimeOfDay? timeOfDay) =>
      copyWith(hour: timeOfDay?.hour, minute: timeOfDay?.minute);

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
