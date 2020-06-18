import 'package:seagull/i18n/translations.dart';

extension TranslatedExtensions on Translated {
  String inTime(String time) => '$inTimePre $time';
  String timeAgo(String time) => '$timeAgoPre $time $timeAgoPost'.trim();
}
