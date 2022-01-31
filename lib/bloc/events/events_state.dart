import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/datetime.dart';

abstract class EventsState extends Equatable {
  const EventsState();
  @override
  List<Object> get props => [];
}

class EventsLoading extends EventsState {
  const EventsLoading() : super();
}

class EventsLoaded extends EventsState {
  final UnmodifiableListView<Event> events;
  final UnmodifiableListView<TimerOccasion> timers;
  final UnmodifiableListView<ActivityDay> activities;
  final UnmodifiableListView<ActivityOccasion> fullDayActivities;

  final Occasion occasion;
  final DateTime day;

  bool get isToday => occasion == Occasion.current;

  EventsLoaded({
    required List<ActivityDay> activities,
    required List<TimerOccasion> timers,
    List<ActivityOccasion> fullDayActivities = const [],
    required this.day,
    required this.occasion,
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
  List<Object> get props => [
        occasion,
        events,
        fullDayActivities,
        day,
      ];

  @override
  String toString() => 'EventsLoaded '
      '$fullDayActivities fullDayActivities, '
      '$activities activities, '
      '$timers timers, '
      '$occasion, ${yMd(day)} }';
}
