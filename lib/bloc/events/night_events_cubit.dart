import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/events/helper.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class NightEventsCubit extends Cubit<EventsLoaded> {
  final MemoplannerSettingBloc memoplannerSettingBloc;
  final ActivitiesBloc activitiesBloc;
  final TimerAlarmBloc timerAlarmBloc;
  final DayPickerBloc dayPickerBloc;
  final ClockBloc clockBloc;

  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _timerSubscription;
  late final StreamSubscription _clockSubscription;
  late final StreamSubscription _daypickerSubscription;
  late final StreamSubscription _memoplannerSettingsSubscription;
  DayParts? _dayParts;

  NightEventsCubit({
    required this.activitiesBloc,
    required this.timerAlarmBloc,
    required this.memoplannerSettingBloc,
    required this.clockBloc,
    required this.dayPickerBloc,
  }) : super(
          _stateCopyWith(
            activitiesBloc.state.activities,
            timerAlarmBloc.state.timers,
            dayPickerBloc.state.day,
            clockBloc.state,
            memoplannerSettingBloc.state.dayParts,
          ),
        ) {
    _clockSubscription = clockBloc.stream.listen((now) => _nowChange(now));
    _activitiesSubscription = activitiesBloc.stream
        .listen((s) => _newState(activities: s.activities));
    _timerSubscription =
        timerAlarmBloc.stream.listen((s) => _newState(timers: s.timers));
    _daypickerSubscription =
        dayPickerBloc.stream.listen((s) => _newState(day: s.day));
    _memoplannerSettingsSubscription = memoplannerSettingBloc.stream
        .where((settingsState) => settingsState.dayParts != _dayParts)
        .listen((settingsState) {
      _dayParts = settingsState.dayParts;
      _newState(dayParts: settingsState.dayParts);
    });
  }

  void _newState({
    List<Activity>? activities,
    List<TimerOccasion>? timers,
    DateTime? day,
    DayParts? dayParts,
  }) =>
      emit(
        _stateCopyWith(
          activities ?? activitiesBloc.state.activities,
          timers ?? timerAlarmBloc.state.timers,
          day ?? dayPickerBloc.state.day,
          clockBloc.state,
          dayParts ?? memoplannerSettingBloc.state.dayParts,
        ),
      );

  void _nowChange(DateTime now) => emit(
        _stateFrom(
          state.activities,
          state.timers,
          dayPickerBloc.state.day,
          now,
          memoplannerSettingBloc.state.dayParts,
        ),
      );

  static EventsLoaded _stateCopyWith(
    List<Activity> activities,
    List<TimerOccasion> timers,
    DateTime day,
    DateTime now,
    DayParts dayParts,
  ) {
    final nightEnd = day.nextDay().add(dayParts.morning);
    final nightStart = day.add(dayParts.night);
    return _stateFrom(
      activities
          .expand(
            (activity) => activity.nightActivitiesForNight(
              day,
              nightStart,
              nightEnd,
            ),
          )
          .toList(),
      timers
          .where((timer) =>
              timer.start.inRangeWithInclusiveStart(
                startDate: nightStart,
                endDate: nightEnd,
              ) ||
              nightStart.inExclusiveRange(
                startDate: timer.start,
                endDate: timer.end,
              ))
          .toList(),
      day,
      now,
      dayParts,
    );
  }

  static EventsLoaded _stateFrom(
    List<ActivityDay> dayActivities,
    List<TimerOccasion> timerOccasions,
    DateTime day,
    DateTime now,
    DayParts dayParts,
  ) =>
      mapToEventsState(
        dayActivities: dayActivities,
        timerOccasions: timerOccasions,
        day: day,
        occasion: isThisNight(
          dayParts,
          now,
          day,
        ),
        includeFullday: false,
      );

  static Occasion isThisNight(DayParts dayParts, DateTime now, DateTime day) {
    final nightStart = day.add(dayParts.night);
    if (now.isBefore(nightStart)) return Occasion.future;

    final dayStart = day.nextDay().add(dayParts.morning);
    if (now.isAfter(dayStart)) return Occasion.past;
    return Occasion.current;
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _timerSubscription.cancel();
    await _clockSubscription.cancel();
    await _daypickerSubscription.cancel();
    await _memoplannerSettingsSubscription.cancel();
    await super.close();
  }
}
