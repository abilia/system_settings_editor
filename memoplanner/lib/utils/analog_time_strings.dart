import 'dart:ui';

import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:meta/meta.dart';

const String _clockNoMinutesTts = '%s';

String analogTimeStringWithInterval(
  Lt translate,
  Locale locale,
  DateTime time,
  DayPart dayPart,
) {
  final timeWithInterval = translate.replaceInString(
      intervalString(translate, dayPart, time.hour),
      analogTimeString(translate, locale, time));
  return translate.replaceInString(
      translate.clockTheTimeIsTts, timeWithInterval);
}

@visibleForTesting
String intervalString(Lt translate, DayPart dayPart, int hour) {
  switch (dayPart) {
    case DayPart.day:
      if (hour > 11) {
        return translate.timeAfternoonTts;
      }
      return translate.timeForeNoonTts;
    case DayPart.evening:
      return translate.timeEveningTts;
    case DayPart.night:
      return translate.timeNightTts;
    case DayPart.morning:
      return translate.timeMorningTts;
  }
}

@visibleForTesting
String analogTimeString(Lt translate, Locale locale, DateTime time) {
  final hour = hourForTime(locale.languageCode, time);
  return translate.replaceInString(_analogMinuteString(translate, time),
      _analogHourString(translate, locale, hour));
}

String _analogHourString(Lt translate, Locale locale, int hour) {
  String hourString = hour.toString();

  if (hour == 1) {
    if (locale.languageCode == 'nb') {
      hourString = translate.nbOneAClock;
    }
    hourString += ' :';
  }
  return hourString;
}

String _analogMinuteString(Lt translate, DateTime time) {
  final interval = fiveMinInterval(time);
  return _stringForInterval(translate, interval);
}

@visibleForTesting
int hourForTime(String language, DateTime time) {
  final minute = time.minute;
  int hour = time.hour;
  if (minute > 17 && language == 'nb') {
    hour++;
  } else if (minute > 22 && (language == 'sv' || language == 'da')) {
    hour++;
  } else if (minute > 32 && language == 'en') {
    hour++;
  }
  hour = (hour % 12);
  if (hour == 0) {
    hour = 12;
  }
  return hour;
}

@visibleForTesting
int fiveMinInterval(DateTime time) {
  return (((time.minute + 2) % 60) / 5).floor();
}

String _stringForInterval(Lt translate, int interval) {
  switch (interval) {
    case 1:
      return translate.clockFiveMinutesPastTts;
    case 2:
      return translate.clockTenMinutesPastTts;
    case 3:
      return translate.clockQuarterPastTts;
    case 4:
      return translate.clockTwentyMinutesPastTts;
    case 5:
      return translate.clockFiveMinutesToHalfPastTts;
    case 6:
      return translate.clockHalfPastTts;
    case 7:
      return translate.clockFiveMinutesHalfPastTts;
    case 8:
      return translate.clockTwentyMinutesToTts;
    case 9:
      return translate.clockQuarterToTts;
    case 10:
      return translate.clockTenMinutesToTts;
    case 11:
      return translate.clockFiveMinutesToTts;
    default:
      return _clockNoMinutesTts;
  }
}
