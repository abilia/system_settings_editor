part of 'day_events_cubit.dart';

// This does not extends Equatable because of preformance issues
// when we do equals on a large amount of DateTime
abstract class DayEventsState {}

class DayEventsUninitialized extends DayEventsState {}

class DayEventsLoaded extends DayEventsState {
  final List<ActivityDay> activities;
  final List<TimerDay> timers;
  final DateTime day;
  final Occasion occasion;

  DayEventsLoaded(
    this.activities,
    this.timers,
    this.day,
    this.occasion,
  );

  @override
  String toString() => 'DayEventsLoaded { ${activities.length} activities, '
      '${timers.length} timers, day: ${yMd(day)}, $occasion }';
}
