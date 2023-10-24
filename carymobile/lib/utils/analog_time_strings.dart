import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:meta/meta.dart';

String analogTimeString(Lt translate, String languageCode, DateTime time) {
  final hour = hourForTime(languageCode, time);
  final minute = _analogMinuteString(translate, time);
  return minute.replaceFirst(
    '%s',
    _analogHourString(translate, languageCode, hour),
  );
}

String _analogHourString(Lt translate, String languageCode, int hour) {
  String hourString = hour.toString();

  if (hour == 1) {
    if (languageCode == 'nb') {
      // hourString = translate.nbOneAClock;
    }
    hourString += ' :';
  }
  return hourString;
}

@visibleForTesting
int hourForTime(String languageCode, DateTime time) {
  final minute = time.minute;
  int hour = time.hour;
  if (minute > 17 && languageCode == 'nb') {
    hour++;
  } else if (minute > 22 && (languageCode == 'sv' || languageCode == 'da')) {
    hour++;
  } else if (minute > 32 && languageCode == 'en') {
    hour++;
  }
  hour = (hour % 12);
  if (hour == 0) {
    hour = 12;
  }
  return hour;
}

String _analogMinuteString(Lt translate, DateTime time) {
  final fiveMinInterval = (((time.minute + 2) % 60) / 5).floor();
  switch (fiveMinInterval) {
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
      return '%s';
  }
}
