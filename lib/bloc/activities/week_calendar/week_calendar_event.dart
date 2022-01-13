part of 'week_calendar_cubit.dart';

abstract class WeekCalendarEvent {
  const WeekCalendarEvent();
}

class NextWeek extends WeekCalendarEvent {}

class PreviousWeek extends WeekCalendarEvent {}

class GoToCurrentWeek extends WeekCalendarEvent {}

class UpdateWeekActivites extends WeekCalendarEvent {
  final Iterable<Activity> activities;

  const UpdateWeekActivites(this.activities);
}
