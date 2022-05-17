import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'week_calendar_state.dart';

class WeekCalendarCubit extends Cubit<WeekCalendarState> {
  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _clockSubscription;
  WeekCalendarCubit({
    required this.activitiesBloc,
    required this.clockBloc,
  }) : super(activitiesBloc.state is ActivitiesLoaded
            ? _mapToState(
                clockBloc.state.firstInWeek(),
                (activitiesBloc.state as ActivitiesLoaded).activities,
                clockBloc.state)
            : WeekCalendarInitial(clockBloc.state.firstInWeek())) {
    _activitiesSubscription = activitiesBloc.stream.listen((state) {
      final activityState = state;
      if (activityState is ActivitiesLoaded) {
        _updateWeekActivities(activityState.activities);
      }
    });
    _clockSubscription = clockBloc.stream.listen((_) {
      final activityState = activitiesBloc.state;
      if (activityState is ActivitiesLoaded) {
        _updateWeekActivities(activityState.activities);
      }
    });
  }

  void nextWeek() => emit(_mapToState(
      state.currentWeekStart.nextWeek(), _activities, clockBloc.state));

  void previousWeek() => emit(_mapToState(
      state.currentWeekStart.previousWeek(), _activities, clockBloc.state));

  void goToCurrentWeek() => emit(
      _mapToState(clockBloc.state.firstInWeek(), _activities, clockBloc.state));

  List<Activity> get _activities => activitiesBloc.state is ActivitiesLoaded
      ? activitiesBloc.state.activities
      : <Activity>[];

  void _updateWeekActivities(List<Activity> activities) => emit(
        _mapToState(
          state.currentWeekStart,
          activities,
          clockBloc.state,
        ),
      );

  static WeekCalendarState _mapToState(
    DateTime weekStart,
    Iterable<Activity> activities,
    DateTime now,
  ) {
    final weekActivityOccasions = {
      for (final dayIndex in List<int>.generate(7, (i) => i))
        dayIndex: occasionsForDay(activities, weekStart.addDays(dayIndex), now)
    };
    return WeekCalendarLoaded(weekStart, weekActivityOccasions);
  }

  static List<ActivityOccasion> occasionsForDay(
      Iterable<Activity> activities, DateTime weekStart, DateTime now) {
    return activities
        .expand((activity) => activity.dayActivitiesForDay(weekStart))
        .where((a) => !(a.activity.removeAfter && a.end.isDayBefore(now)))
        .map((e) => e.toOccasion(now))
        .toList()
      ..sort((a, b) =>
          a.activity.startClock(a.day).compareTo(b.activity.startClock(b.day)));
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _clockSubscription.cancel();
    return super.close();
  }
}
