import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'week_calendar_state.dart';

class WeekCalendarCubit extends Cubit<WeekCalendarState> {
  final ActivityRepository activityRepository;
  final ClockBloc clockBloc;
  final TimerAlarmBloc timerAlarmBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _timersSubscription;
  late final StreamSubscription _clockSubscription;

  WeekCalendarCubit({
    required ActivitiesBloc activitiesBloc,
    required this.activityRepository,
    required this.timerAlarmBloc,
    required this.clockBloc,
  }) : super(WeekCalendarInitial(clockBloc.state.firstInWeek())) {
    _activitiesSubscription = activitiesBloc.stream.listen((_) {
      _mapToState(state.currentWeekStart, clockBloc.state);
    });
    _timersSubscription = timerAlarmBloc.stream.listen((_) {
      _mapToState(state.currentWeekStart, clockBloc.state);
    });
    _clockSubscription = clockBloc.stream.listen((_) {
      _mapToState(state.currentWeekStart, clockBloc.state);
    });
  }

  Future<void> nextWeek() {
    return _mapToState(state.currentWeekStart.nextWeek(), clockBloc.state);
  }

  Future<void> previousWeek() {
    return _mapToState(state.currentWeekStart.previousWeek(), clockBloc.state);
  }

  Future<void> goToCurrentWeek() {
    return _mapToState(clockBloc.state.firstInWeek(), clockBloc.state);
  }

  Future<void> _mapToState(
    DateTime weekStart,
    DateTime now,
  ) async {
    final activities =
        await activityRepository.allBetween(weekStart, weekStart.addDays(7));
    final weekActivityOccasions = {
      for (final dayIndex in List<int>.generate(7, (i) => i))
        dayIndex: _activityOccasionsForDay(
            activities, weekStart.addDays(dayIndex), now)
    };
    final timerOccasions = timerAlarmBloc.state.timers;
    final weekTimerOccasions = {
      for (final dayIndex in List<int>.generate(7, (i) => i))
        dayIndex: _timerOccasionsForDay(
            timerOccasions, weekStart.addDays(dayIndex), now)
    };
    emit(WeekCalendarLoaded(
        weekStart, weekActivityOccasions, weekTimerOccasions));
  }

  List<ActivityOccasion> _activityOccasionsForDay(
      Iterable<Activity> activities, DateTime day, DateTime now) {
    return activities
        .expand((activity) => activity.dayActivitiesForDay(day))
        .removeAfter(now)
        .map((e) => e.toOccasion(now))
        .toList()
      ..sort((a, b) =>
          a.activity.startClock(a.day).compareTo(b.activity.startClock(b.day)));
  }

  List<TimerOccasion> _timerOccasionsForDay(
      Iterable<TimerOccasion> timerOccasions, DateTime day, DateTime now) {
    return timerOccasions
        .onDay(now)
        .where((occasion) => occasion.start.isAtSameDay(day))
        .toList();
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _timersSubscription.cancel();
    await _clockSubscription.cancel();
    return super.close();
  }
}
