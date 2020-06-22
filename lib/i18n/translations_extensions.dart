import 'package:seagull/i18n/all.dart';

extension TranslatedExtensions on Translated {
  String inTime(String time) => '$inTimePre $time';
  String timeAgo(String time) => '$timeAgoPre $time $timeAgoPost'.trim();
}
