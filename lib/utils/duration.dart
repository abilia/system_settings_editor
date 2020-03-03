import 'package:seagull/i18n/translations.dart';

extension IntToDuration on int {
  Duration days() => Duration(days: this);
  Duration hours() => Duration(hours: this);
  Duration minutes() => Duration(minutes: this);
  Duration seconds() => Duration(seconds: this);
  Duration milliseconds() => Duration(milliseconds: this);
}

extension DurationToString on Duration {
  String toReminderString(Translated translater) {
    if (inDays > 1) return '$inDays ${translater.days}';
    if (inDays == 1) return '$inDays ${translater.day}';
    if (inHours > 1) return '$inHours ${translater.hours}';
    if (inHours == 1) return '$inHours ${translater.hour}';
    return '$inMinutes ${translater.min}';
  }
}
