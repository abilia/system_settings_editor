import 'package:memoplanner/i18n/app_localizations.dart';
import 'package:memoplanner/i18n/translations_extensions.dart';
import 'package:memoplanner/models/all.dart';
import 'package:meta/meta.dart';

const String _clockNoMinutesTts = '%s';

String analogTimeStringWithInterval(
  Translator translator,
  DateTime time,
  DayPart dayPart,
) {
  final timeWithInterval = translator.translate.replaceInString(
      intervalString(translator, dayPart, time.hour),
      analogTimeString(translator, time));
  return translator.translate.replaceInString(
      translator.translate.clockTheTimeIsTts, timeWithInterval);
}

@visibleForTesting
String intervalString(Translator translator, DayPart dayPart, int hour) {
  switch (dayPart) {
    case DayPart.day:
      if (hour > 11) {
        return translator.translate.timeAfternoonTts;
      }
      return translator.translate.timeForeNoonTts;
    case DayPart.evening:
      return translator.translate.timeEveningTts;
    case DayPart.night:
      return translator.translate.timeNightTts;
    case DayPart.morning:
      return translator.translate.timeMorningTts;
  }
}

@visibleForTesting
String analogTimeString(Translator translator, DateTime time) {
  final hour = hourForTime(translator.locale.languageCode, time);
  return translator.translate.replaceInString(
      _analogMinuteString(translator, time),
      _analogHourString(translator, hour));
}

String _analogHourString(Translator translator, int hour) {
  String hourString = hour.toString();

  if (hour == 1) {
    if (translator.locale.languageCode == 'nb') {
      hourString = translator.translate.nbOneAClock;
    }
    hourString += ' :';
  }
  return hourString;
}

String _analogMinuteString(Translator translator, DateTime time) {
  final interval = fiveMinInterval(time);
  return _stringForInterval(translator, interval);
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

String _stringForInterval(Translator translator, int interval) {
  final translate = translator.translate;
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
