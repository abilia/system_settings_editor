import 'dart:async';

import 'package:collection/collection.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

part 'week_calendar_state.dart';

class WeekCalendarCubit extends Cubit<WeekCalendarState> {
  final ActivityRepository activityRepository;
  final ClockBloc clockBloc;
  final TimerAlarmBloc timerAlarmBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _timersSubscription;
  late final StreamSubscription _clockSubscription;
  // Makes animated page transitions possible in WeekCalendar
  late WeekCalendarState previousState = state;

  WeekCalendarCubit({
    required ActivitiesCubit activitiesCubit,
    required this.activityRepository,
    required this.timerAlarmBloc,
    required this.clockBloc,
  }) : super(WeekCalendarInitial(clockBloc.state.firstInWeek())) {
    _activitiesSubscription = activitiesCubit.stream.listen(
        (_) async => _mapToState(state.currentWeekStart, clockBloc.state));
    _timersSubscription = timerAlarmBloc.stream.listen(
        (_) async => _mapToState(state.currentWeekStart, clockBloc.state));
    _clockSubscription = clockBloc.stream.listen(
        (_) async => _mapToState(state.currentWeekStart, clockBloc.state));
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
    final timerOccasions = timerAlarmBloc.state.timers;
    final weekEventOccasions = {
      for (final dayIndex in List<int>.generate(7, (i) => i))
        dayIndex: [
          ..._activityOccasionsForDay(
              activities, weekStart.addDays(dayIndex), now),
          ..._timerOccasionsForDay(timerOccasions, weekStart.addDays(dayIndex))
        ]
    };

    final mapByFullDay = weekEventOccasions.map(
      (key, value) => MapEntry(
        key,
        value.groupListsBy(
          (eventDay) =>
              eventDay is ActivityOccasion && eventDay.activity.fullDay,
        ),
      ),
    );
    final fullDayActivities = mapByFullDay.map(
      (key, value) => MapEntry(
        key,
        value[true]?.whereType<ActivityOccasion>().toList() ?? [],
      ),
    );
    final noneFullDayEvents = mapByFullDay.map(
      (key, value) => MapEntry(
        key,
        (value[false] ?? [])..sort(),
      ),
    );

    previousState = state;

    if (isClosed) return;
    emit(WeekCalendarLoaded(weekStart, noneFullDayEvents, fullDayActivities));
  }

  List<ActivityOccasion> _activityOccasionsForDay(
      Iterable<Activity> activities, DateTime day, DateTime now) {
    return activities
        .expand((activity) => activity.dayActivitiesForDay(day))
        .removeAfter(now)
        .map((e) => e.toOccasion(now))
        .toList();
  }

  List<TimerOccasion> _timerOccasionsForDay(
      Iterable<TimerOccasion> timerOccasions, DateTime day) {
    return timerOccasions
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
