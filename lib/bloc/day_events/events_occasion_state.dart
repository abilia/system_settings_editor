part of 'events_occasion_cubit.dart';

abstract class EventsOccasionState extends Equatable {
  const EventsOccasionState();
  @override
  List<Object> get props => [];
}

class EventsOccasionLoading extends EventsOccasionState {
  const EventsOccasionLoading() : super();
}

class EventsOccasionLoaded extends EventsOccasionState {
  final List<EventDay> events;
  final List<TimerDay> timers;
  final List<ActivityDay> activities;

  final List<ActivityOccasion> fullDayActivities;

  final Occasion occasion;
  final DateTime day;

  bool get isToday => occasion == Occasion.current;

  EventsOccasionLoaded({
    required this.activities,
    required this.timers,
    this.fullDayActivities = const [],
    required this.day,
    required this.occasion,
  })  : events = [...activities, ...timers]..sort(), // TODO Unecessary to sort?
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
  String toString() => 'EventsOccasionLoaded '
      '$fullDayActivities fullDayActivities, '
      '$activities activities, '
      '$timers timers, '
      '$occasion, ${yMd(day)} }';
}
