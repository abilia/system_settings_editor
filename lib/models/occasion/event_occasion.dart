import 'package:seagull/models/occasion/all.dart';

enum Occasion { past, current, future }

abstract class EventOccasion extends Event implements Comparable {
  const EventOccasion(this.occasion);
  final Occasion occasion;
  bool get isPast => occasion.isPast;
}

extension OccasionExtension on Occasion {
  bool get isToday => this == Occasion.current;
  bool get isPast => this == Occasion.past;
  bool get isFuture => this == Occasion.future;
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
