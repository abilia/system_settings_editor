part of 'week_calendar_bloc.dart';

final DateTime zero = DateTime.fromMillisecondsSinceEpoch(0);

abstract class WeekCalendarState {
  final DateTime currentWeekStart;
  final Map<int, List<ActivityOccasion>> currentWeekActivities;

  int get index => currentWeekStart.difference(zero).inDays ~/ 7;

  const WeekCalendarState(
    this.currentWeekStart,
    this.currentWeekActivities,
  );
}

class WeekCalendarInitial extends WeekCalendarState {
  const WeekCalendarInitial(DateTime currentWeekStart)
      : super(
          currentWeekStart,
          const {},
        );
}

class WeekCalendarLoaded extends WeekCalendarState {
  const WeekCalendarLoaded(
    DateTime currentWeekStart,
    Map<int, List<ActivityOccasion>> currentWeekActivities,
  ) : super(currentWeekStart, currentWeekActivities);

  @override
  String toString() =>
      'WeekCalendarLoaded { currentWeekStart: $currentWeekStart, activities: ${currentWeekActivities.length} }';
}
