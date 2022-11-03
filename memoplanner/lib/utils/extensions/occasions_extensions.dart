import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

extension TimerOccasionsExtentions on Iterable<TimerOccasion> {
  List<TimerOccasion> onDay(DateTime day) => where((timerOccasion) =>
      timerOccasion.start.isAtSameDay(day) ||
      timerOccasion.end.isAtSameDay(day)).toList();
}
