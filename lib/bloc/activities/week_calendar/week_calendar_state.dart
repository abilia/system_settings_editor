part of 'week_calendar_bloc.dart';

abstract class WeekCalendarState extends Equatable {
  final DateTime ZERO = DateTime.fromMillisecondsSinceEpoch(0);
  final DateTime currentWeekStart;
  final Map<int, List<ActivityOccasion>> currentWeekActivities;

  int get index => currentWeekStart.difference(ZERO).inDays ~/ 7;

  WeekCalendarState(
    this.currentWeekStart,
    this.currentWeekActivities,
  );

  @override
  List<Object> get props => [currentWeekStart, currentWeekActivities];
}

class WeekCalendarInitial extends WeekCalendarState {
  WeekCalendarInitial(DateTime currentWeekStart) : super(currentWeekStart, {});
}

class WeekCalendarLoaded extends WeekCalendarState {
  WeekCalendarLoaded(
      DateTime currentWeekStart, Map<int, List<ActivityOccasion>> as)
      : super(currentWeekStart, as);

  @override
  String toString() =>
      'WeekCalendarLoaded { currentWeekStart: $currentWeekStart, activities: $currentWeekActivities}';
}
