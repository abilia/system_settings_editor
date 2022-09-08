import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

extension TimerOccasionsExtentions on Iterable<TimerOccasion> {
  List<TimerOccasion> onDay(DateTime day) => where((timerOccasion) =>
      timerOccasion.start.isAtSameDay(day) ||
      timerOccasion.end.isAtSameDay(day)).toList();
}
