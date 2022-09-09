import 'dart:async';

import 'package:seagull/bloc/all.dart';
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
  }) : super(
          activitiesBloc.state is ActivitiesLoaded
              ? _mapToState(
                  activitiesBloc.state.activities,
                  timerAlarmBloc.state.timers,
                  dayPickerBloc.state.day,
                  dayPickerBloc.state.occasion,
                )
              : EventsLoading(
                  dayPickerBloc.state.day,
                  dayPickerBloc.state.occasion,
                ),
        ) {
    _activitiesSubscription = activitiesBloc.stream
        .listen((state) => _updateState(activities: state.activities));
    _dayPickerSubscription = dayPickerBloc.stream.listen(
        ((state) => _updateState(day: state.day, occasion: state.occasion)));
    _timerSubscription = timerAlarmBloc.stream
        .listen((state) => _updateState(timers: state.timers));
  }

  void _updateState({
    List<Activity>? activities,
    List<TimerOccasion>? timers,
    DateTime? day,
    Occasion? occasion,
  }) =>
      emit(
        _mapToState(
          activities ?? activitiesBloc.state.activities,
          timers ?? timerAlarmBloc.state.timers,
          day ?? dayPickerBloc.state.day,
          occasion ?? dayPickerBloc.state.occasion,
        ),
      );

  static EventsState _mapToState(
    Iterable<Activity> activities,
    Iterable<TimerOccasion> timerOccasions,
    DateTime day,
    Occasion occasion,
  ) {
    final dayActivities = activities
        .expand((activity) => activity.dayActivitiesForDay(day))
        .removeAfterOccasion(occasion)
        .toList();
    final fullDayOccasion = occasion.isPast ? Occasion.past : Occasion.future;
    return EventsState(
      activities: dayActivities
          .where((activityDay) => !activityDay.activity.fullDay)
          .toList(),
      timers: timerOccasions.onDay(day),
      fullDayActivities: dayActivities
          .where((activityDay) => activityDay.activity.fullDay)
          .map((e) => ActivityOccasion(e.activity, day, fullDayOccasion))
          .toList(),
      day: day,
      occasion: occasion,
    );
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _dayPickerSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}
