import 'dart:collection';

import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class EventsState {
  final UnmodifiableListView<Event> events;
  final UnmodifiableListView<TimerOccasion> timers;
  final UnmodifiableListView<ActivityDay> activities;
  final UnmodifiableListView<ActivityOccasion> fullDayActivities;

  final Occasion occasion;
  final DateTime day;

  bool get isToday => occasion == Occasion.current;

  EventsState({
    required List<ActivityDay> activities,
    required List<TimerOccasion> timers,
    required this.day,
    required this.occasion,
    List<ActivityOccasion> fullDayActivities = const [],
  })  : activities = UnmodifiableListView(activities),
        timers = UnmodifiableListView(timers),
        fullDayActivities = UnmodifiableListView(fullDayActivities),
        events = UnmodifiableListView([...activities, ...timers]),
        super();

  List<EventOccasion> pastEvents(DateTime now) => events
      .where((event) => event.end.isBefore(now))
      .map((e) => e.toOccasion(now))
      .toList()
    ..sort();

  List<EventOccasion> notPastEvents(DateTime now) => events
      .where((event) => event.end.isAtSameMomentOrAfter(now))
      .map((e) => e.toOccasion(now))
      .toList()
    ..sort();

  @override
  String toString() => 'EventsState '
      '$fullDayActivities fullDayActivities, '
      '$activities activities, '
      '$timers timers, '
      '$occasion, ${yMd(day)} }';
}

class EventsLoading extends EventsState {
  EventsLoading(
    DateTime day,
    Occasion occasion,
  ) : super(
          activities: [],
          timers: [],
          day: day,
          occasion: occasion,
        );
}
