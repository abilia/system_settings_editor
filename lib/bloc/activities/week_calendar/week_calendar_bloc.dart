import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'week_calendar_event.dart';
part 'week_calendar_state.dart';

class WeekCalendarBloc extends Bloc<WeekCalendarEvent, WeekCalendarState> {
  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  StreamSubscription _activitiesSubscription;
  WeekCalendarBloc({
    @required this.activitiesBloc,
    @required this.clockBloc,
  }) : super(activitiesBloc.state is ActivitiesLoaded
            ? _mapToState(
                clockBloc.state.firstInWeek(),
                (activitiesBloc.state as ActivitiesLoaded).activities,
                clockBloc.state)
            : WeekCalendarInitial(clockBloc.state.firstInWeek())) {
    _activitiesSubscription = activitiesBloc.listen((state) {
      final activityState = state;
      if (activityState is ActivitiesLoaded) {
        add(UpdateWeekActivites(activityState.activities));
      }
    });
  }

  @override
  Stream<WeekCalendarState> mapEventToState(
    WeekCalendarEvent event,
  ) async* {
    final activityState = activitiesBloc.state;
    final activities =
        activityState is ActivitiesLoaded ? activityState.activities : [];
    if (event is NextWeek) {
      yield _mapToState(
          state.currentWeekStart.nextWeek(), activities, clockBloc.state);
    } else if (event is PreviousWeek) {
      final s = _mapToState(
          state.currentWeekStart.previousWeek(), activities, clockBloc.state);
      yield s;
    } else if (event is UpdateWeekActivites) {
      yield _mapToState(
          state.currentWeekStart, event.activities, clockBloc.state);
    }
  }

  static WeekCalendarState _mapToState(
    DateTime weekStart,
    Iterable<Activity> activities,
    DateTime now,
  ) {
    final as = {
      1: occasionsForDay(activities, weekStart, now),
      2: occasionsForDay(
          activities, weekStart.copyWith(day: weekStart.day + 1), now),
      3: occasionsForDay(
          activities, weekStart.copyWith(day: weekStart.day + 2), now),
      4: occasionsForDay(
          activities, weekStart.copyWith(day: weekStart.day + 3), now),
      5: occasionsForDay(
          activities, weekStart.copyWith(day: weekStart.day + 4), now),
      6: occasionsForDay(
          activities, weekStart.copyWith(day: weekStart.day + 5), now),
      7: occasionsForDay(
          activities, weekStart.copyWith(day: weekStart.day + 6), now),
    };
    return WeekCalendarLoaded(weekStart, as);
  }

  static List<ActivityOccasion> occasionsForDay(
      Iterable<Activity> activities, DateTime weekStart, DateTime now) {
    return activities
        .expand((activity) => activity.dayActivitiesForDay(weekStart))
        .map((e) => e.toOccasion(now))
        .toList();
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    return super.close();
  }
}
