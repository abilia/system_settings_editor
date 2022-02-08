import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/events/helper.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class DayEventsCubit extends Cubit<EventsState> {
  final ActivitiesBloc activitiesBloc;
  final TimerAlarmBloc timerAlarmBloc;
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _timerSubscription;
  late final StreamSubscription _dayPickerSubscription;

  DayEventsCubit({
    required this.activitiesBloc,
    required this.dayPickerBloc,
    required this.timerAlarmBloc,
  }) : super(activitiesBloc.state is ActivitiesLoaded
            ? _mapToState(
                (activitiesBloc.state as ActivitiesLoaded).activities,
                timerAlarmBloc.state.timers,
                dayPickerBloc.state.day,
                dayPickerBloc.state.occasion,
              )
            : const EventsLoading()) {
    _activitiesSubscription = activitiesBloc.stream
        .whereType<ActivitiesLoaded>()
        .listen(_activitiesUpdated);
    _dayPickerSubscription = dayPickerBloc.stream.listen(_dayUpdated);
    _timerSubscription = timerAlarmBloc.stream.listen(_updateState);
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
          timerAlarmBloc.state.timers,
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
          timerAlarmBloc.state.timers,
          state.day,
          state.occasion,
        ),
      );
    }
  }

  static EventsState _mapToState(
    final Iterable<Activity> activities,
    final Iterable<TimerOccasion> timers,
    final DateTime day,
    final Occasion occasion,
  ) =>
      mapToEventsState(
        dayActivities: activities
            .expand((activity) => activity.dayActivitiesForDay(day))
            .toList(),
        timerOccasions: timers
            .where((timer) =>
                timer.start.isAtSameDay(day) || timer.end.isAtSameDay(day))
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
