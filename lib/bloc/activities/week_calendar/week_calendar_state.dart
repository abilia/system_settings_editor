part of 'week_calendar_bloc.dart';

abstract class WeekCalendarState extends Equatable {
  final DateTime currentWeekStart;
  final Map<int, List<ActivityOccasion>> as;
  const WeekCalendarState(
    this.currentWeekStart,
    this.as,
  );

  @override
  List<Object> get props => [currentWeekStart, as];
}

class WeekCalendarInitial extends WeekCalendarState {
  WeekCalendarInitial(DateTime currentWeekStart) : super(currentWeekStart, {});
}

class WeekCalendarLoaded extends WeekCalendarState {
  WeekCalendarLoaded(
      DateTime currentWeekStart, Map<int, List<ActivityOccasion>> as)
      : super(currentWeekStart, as);
}
