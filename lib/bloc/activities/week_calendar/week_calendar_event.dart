part of 'week_calendar_bloc.dart';

abstract class WeekCalendarEvent extends Equatable {
  const WeekCalendarEvent();

  @override
  List<Object> get props => [];
}

class NextWeek extends WeekCalendarEvent {}

class PreviousWeek extends WeekCalendarEvent {}

class GoToCurrentWeek extends WeekCalendarEvent {}

class UpdateWeekActivites extends WeekCalendarEvent {
  final Iterable<Activity> activities;

  UpdateWeekActivites(this.activities);

  @override
  List<Object> get props => [activities];
}
