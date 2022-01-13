import 'dart:async';

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
            : DayEventsUninitialized()) {
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
      DayEventsLoaded(
        activities
            .expand((activity) => activity.dayActivitiesForDay(day))
            .toList(),
        timers
            .where((timer) =>
                timer.startTime.isAtSameDay(day) ||
                timer.endTime.isAtSameDay(day))
            .map((timer) => TimerDay(timer, day))
            .toList(),
        day,
        occasion,
      );

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}
