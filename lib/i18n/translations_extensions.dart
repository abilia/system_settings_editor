import 'package:seagull/i18n/all.dart';

extension TranslatedExtensions on Translated {
  String inTime(String time) => '$inTimePre $time';
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
}
