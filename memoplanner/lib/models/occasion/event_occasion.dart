import 'package:memoplanner/models/occasion/all.dart';

enum Occasion { past, current, future }

abstract class EventOccasion extends Event {
  const EventOccasion(this.occasion);
  final Occasion occasion;
  bool get isPast => occasion.isPast;
  bool get isCurrent => occasion.isCurrent;
  bool get isFuture => occasion.isFuture;

  @override
  int compareTo(other) {
    final occasionComparing = occasion.index.compareTo(other.occasion.index);
    if (occasionComparing != 0) return occasionComparing;
    return super.compareTo(other);
  }
}

extension OccasionExtension on Occasion {
  bool get isCurrent => this == Occasion.current;
  bool get isPast => this == Occasion.past;
  bool get isFuture => this == Occasion.future;
}
