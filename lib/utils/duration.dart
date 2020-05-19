import 'package:seagull/i18n/translations.dart';

extension IntToDuration on int {
  Duration days() => Duration(days: this);
  Duration hours() => Duration(hours: this);
  Duration minutes() => Duration(minutes: this);
  Duration seconds() => Duration(seconds: this);
  Duration milliseconds() => Duration(milliseconds: this);
}

extension DurationExtensions on Duration {
  String toReminderString(Translated translater) {
    if (inDays > 1) return '$inDays ${translater.days}';
    if (inDays == 1) return '$inDays ${translater.day}';
    if (inHours > 1) return '$inHours ${translater.hours}';
    if (inHours == 1) return '$inHours ${translater.hour}';
    return '$inMinutes ${translater.min}';
  }

  String toUntilString(Translated translater) {
    final sb = StringBuffer();
    if (inHours > 0) {
      sb.writeln('$inHours ${translater.h}');
    }
    final minutes = inMinutes % Duration.minutesPerHour;
    if (minutes > 0) {
      sb.writeln('$minutes ${translater.min}');
    }
    return sb.toString();
  }

  String toReminderHeading(Translated translater) {
    if (isNegative) {
      return translater.minutesAgo(-inMinutes);
    }
    return translater.inMinutes(inMinutes);
  }

  int inDots(int minutesPerDot, roundingMinute) =>
      (inMinutes ~/ minutesPerDot) +
      (inMinutes % minutesPerDot > roundingMinute ? 1 : 0);
}
