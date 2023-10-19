part of 'week_calendar_cubit.dart';

final DateTime zero = DateTime.fromMillisecondsSinceEpoch(0);

abstract class WeekCalendarState {
  final DateTime currentWeekStart;
  final Map<int, List<EventOccasion>> currentWeekEvents;
  final Map<int, List<ActivityOccasion>> fullDayActivities;

  int get index => currentWeekStart.difference(zero).inDays ~/ 7;

  const WeekCalendarState(
    this.currentWeekStart,
    this.currentWeekEvents,
    this.fullDayActivities,
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
    super.currentWeekStart,
    super.currentWeekEvents,
    super.fullDayActivities,
  );

  @override
  String toString() =>
      'WeekCalendarLoaded { currentWeekStart: $currentWeekStart, events: '
      '${currentWeekEvents.length} full day: ${fullDayActivities.length} }';
}
