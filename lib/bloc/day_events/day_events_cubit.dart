import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'day_events_state.dart';

class DayEventsCubit extends Cubit<DayEventsState> {
  final ActivitiesBloc activitiesBloc;
  final TimerCubit timerCubit;
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _timerSubscription;
  late final StreamSubscription _dayPickerSubscription;

  DayEventsCubit({
    required this.activitiesBloc,
    required this.dayPickerBloc,
    required this.timerCubit,
  }) : super(activitiesBloc.state is ActivitiesLoaded
            ? _mapToState(
                (activitiesBloc.state as ActivitiesLoaded).activities,
                timerCubit.state.timers,
                dayPickerBloc.state.day,
                dayPickerBloc.state.occasion,
              )
            : const DayEventsLoading()) {
    _activitiesSubscription = activitiesBloc.stream
        .whereType<ActivitiesLoaded>()
        .listen(_activitiesUpdated);
    _dayPickerSubscription = dayPickerBloc.stream.listen(_dayUpdated);
    _timerSubscription = timerCubit.stream.listen(_updateState);
  }

  void _activitiesUpdated(final ActivitiesLoaded activityState) =>
      _updateGivenActivities(activityState.activities);

  void _updateState(_) {
    final activityState = activitiesBloc.state;
    _updateGivenActivities(
        activityState is ActivitiesLoaded ? activityState.activities : []);
  }

  void _updateGivenActivities(final List<Activity> activities) => emit(
        _mapToState(
          activities,
          timerCubit.state.timers,
          dayPickerBloc.state.day,
          dayPickerBloc.state.occasion,
        ),
      );

  void _dayUpdated(final DayPickerState state) {
    final activityState = activitiesBloc.state;
    if (activityState is ActivitiesLoaded) {
      emit(
        _mapToState(
          activityState.activities,
          timerCubit.state.timers,
          state.day,
          state.occasion,
        ),
      );
    }
  }

  static DayEventsState _mapToState(
    final Iterable<Activity> activities,
    final Iterable<AbiliaTimer> timers,
    final DateTime day,
    final Occasion occasion,
  ) =>
      mapActivitiesToActivityOccasionsState(
        dayActivities: activities
            .expand((activity) => activity.dayActivitiesForDay(day))
            .toList(),
        dayTimers: timers
            .where((timer) =>
                timer.startTime.isAtSameDay(day) ||
                timer.endTime.isAtSameDay(day))
            .map((timer) => TimerDay(timer, day))
            .toList(),
        occasion: occasion,
        day: day,
      );

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}

DayEventsLoaded mapActivitiesToActivityOccasionsState({
  required List<ActivityDay> dayActivities,
  required List<TimerDay> dayTimers,
  required Occasion occasion,
  required DateTime day,
  bool includeFullday = true,
}) {
  switch (occasion) {
    case Occasion.past:
      return _createState(
        activities: dayActivities.where(
          (activity) =>
              !activity.activity.removeAfter || occasion != Occasion.past,
        ),
        timers: dayTimers,
        day: day,
        dayOccasion: occasion,
      );
    case Occasion.future:
    case Occasion.current:
    default:
      return _createState(
        activities: dayActivities,
        timers: dayTimers,
        day: day,
        dayOccasion: occasion,
      );
  }
}

DayEventsLoaded _createState({
  required Iterable<ActivityDay> activities,
  required List<TimerDay> timers,
  required DateTime day,
  required Occasion dayOccasion,
  bool fulldays = true,
}) {
  final timedActivities =
      activities.where((activityDay) => !activityDay.activity.fullDay).toList();

  final fullDayOccasion =
      dayOccasion == Occasion.past ? Occasion.past : Occasion.future;
  return DayEventsLoaded(
    activities: timedActivities,
    timers: timers,
    fullDayActivities: fulldays
        ? activities
            .where((activityDay) => activityDay.activity.fullDay)
            .map((e) => ActivityOccasion(e.activity, day, fullDayOccasion))
            .toList()
        : [],
    day: day,
    occasion: dayOccasion,
  );
}
