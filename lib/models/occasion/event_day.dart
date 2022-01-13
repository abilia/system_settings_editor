import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

abstract class EventDay<E extends Event> extends Equatable
    implements Comparable {
  final E event;
  final DateTime day;

  const EventDay(this.event, this.day);

  DateTime get start => event.startClock(day);
  DateTime get end => event.endClock(day);

  EventOccasion toOccasion(DateTime now);

  @override
  List<Object> get props => [event, day];

  @override
  int compareTo(other) {
    final starTimeComparing = start.compareTo(other.start);
    if (starTimeComparing != 0) return starTimeComparing;
    return end.compareTo(other.end);
  }
}

abstract class EventOccasion<E extends Event> extends EventDay<E> {
  const EventOccasion(E event, DateTime day) : super(event, day);

  Occasion get occasion;

  @override
  int compareTo(other) {
    final occasionComparing = occasion.index.compareTo(other.occasion.index);
    if (occasionComparing != 0) return occasionComparing;
    return super.compareTo(other);
  }
}
