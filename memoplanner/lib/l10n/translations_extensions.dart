import 'package:flutter/cupertino.dart';
import 'package:memoplanner/l10n/generated/l10n.dart';

extension TranslatedExtensions on Lt {
  static const String _stringWildcard = '%s';
  String inTime(String time) => '$inTimePre $time'.trim();
  String timeAgo(String time) => '$timeAgoPre $time $timeAgoPost'.trim();

  String shortWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return mo;
      case DateTime.tuesday:
        return tu;
      case DateTime.wednesday:
        return we;
      case DateTime.thursday:
        return th;
      case DateTime.friday:
        return fr;
      case DateTime.saturday:
        return sa;
      case DateTime.sunday:
        return su;
      default:
        return '';
    }
  }

  String get allowNotificationsDescription =>
      '$allowNotificationsDescription1 $settingsLink';

  String allowAccess(String accessTypeBodyText1) =>
      '$accessTypeBodyText1 $allowAccessBody2 $settingsLink';

  String replaceInString(String string, String replacement) =>
      string.replaceFirst(_stringWildcard, replacement);
}

@visibleForTesting
Future<Lt> get englishTranslate =>
    Lt.load(const Locale.fromSubtags(languageCode: 'en'));
