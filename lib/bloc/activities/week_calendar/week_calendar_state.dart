part of 'week_calendar_cubit.dart';

final DateTime zero = DateTime.fromMillisecondsSinceEpoch(0);

abstract class WeekCalendarState {
  final DateTime currentWeekStart;
  final Map<int, List<ActivityOccasion>> currentWeekActivities;
  final Map<int, List<TimerOccasion>> currentWeekTimers;

  List<ActivityOccasion> fullDayActivities(DateTime day) =>
      currentWeekActivities[day.weekday - 1]
          ?.where((a) => a.activity.fullDay)
          .toList() ??
      [];

  int get index => currentWeekStart.difference(zero).inDays ~/ 7;

  const WeekCalendarState(
    this.currentWeekStart,
    this.currentWeekActivities,
    this.currentWeekTimers,
  );
}

class WeekCalendarInitial extends WeekCalendarState {
  const WeekCalendarInitial(DateTime currentWeekStart)
      : super(
          currentWeekStart,
          const {},
          const {},
        );
}

class WeekCalendarLoaded extends WeekCalendarState {
  const WeekCalendarLoaded(
    DateTime currentWeekStart,
    Map<int, List<ActivityOccasion>> currentWeekActivities,
    Map<int, List<TimerOccasion>> currentWeekTimers,
  ) : super(currentWeekStart, currentWeekActivities, currentWeekTimers);

  @override
  String toString() =>
      'WeekCalendarLoaded { currentWeekStart: $currentWeekStart, activities: ${currentWeekActivities.length}, timers: ${currentWeekTimers.length} }';
}
