import 'package:seagull/models/occasion/all.dart';

enum Occasion { past, current, future }

abstract class EventOccasion extends Event implements Comparable {
  const EventOccasion(this.occasion);
  final Occasion occasion;
  bool get isPast => occasion.isPast;
  bool get isCurrent => occasion.isCurrent;
}

extension OccasionExtension on Occasion {
  bool get isCurrent => this == Occasion.current;
  bool get isPast => this == Occasion.past;
}

extension Comparer on EventOccasion {
  int compare(EventOccasion other) {
    final occasionComparing = occasion.index.compareTo(other.occasion.index);
    if (occasionComparing != 0) return occasionComparing;
    final starTimeComparing = start.compareTo(other.start);
    if (starTimeComparing != 0) return starTimeComparing;
    return end.compareTo(other.end);
  }
}
