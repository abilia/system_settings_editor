import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/events/helper.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class NightActivitiesCubit extends Cubit<EventsLoaded> {
  final MemoplannerSettingBloc memoplannerSettingBloc;
  final ActivitiesBloc activitiesBloc;
  final DayPickerBloc dayPickerBloc;
  final ClockBloc clockBloc;

  late final StreamSubscription _activitiesSubscription;
  late final StreamSubscription _clockSubscription;
  late final StreamSubscription _daypickerSubscription;
  late final StreamSubscription _memoplannerSettingsSubscription;
  DayParts? _dayParts;

  NightActivitiesCubit({
    required this.activitiesBloc,
    required this.memoplannerSettingBloc,
    required this.clockBloc,
    required this.dayPickerBloc,
  }) : super(
          _stateFromActivities(
            activitiesBloc.state.activities,
            dayPickerBloc.state.day,
            clockBloc.state,
            memoplannerSettingBloc.state.dayParts,
          ),
        ) {
    _clockSubscription = clockBloc.stream.listen((now) => _nowChange(now));
    _activitiesSubscription = activitiesBloc.stream
        .listen((s) => _newState(activities: s.activities));
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
    DateTime? day,
    DayParts? dayParts,
  }) =>
      emit(
        _stateFromActivities(
          activities ?? activitiesBloc.state.activities,
          day ?? dayPickerBloc.state.day,
          clockBloc.state,
          dayParts ?? memoplannerSettingBloc.state.dayParts,
        ),
      );

  void _nowChange(DateTime now) => emit(
        _stateFromActivityDays(
          state.activities,
          dayPickerBloc.state.day,
          now,
          memoplannerSettingBloc.state.dayParts,
        ),
      );

  static EventsLoaded _stateFromActivities(
    List<Activity> activities,
    DateTime day,
    DateTime now,
    DayParts dayParts,
  ) =>
      _stateFromActivityDays(
        activities
            .expand(
              (activity) => activity.nightActivitiesForDay(
                day,
                dayParts,
              ),
            )
            .toList(),
        day,
        now,
        dayParts,
      );

  static EventsLoaded _stateFromActivityDays(
    List<ActivityDay> dayActivities,
    DateTime day,
    DateTime now,
    DayParts dayParts,
  ) =>
      mapToEventsState(
        dayActivities: dayActivities,
        dayTimers: [], // TODO add timers to night cubit
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
    await super.close();
    await _activitiesSubscription.cancel();
    await _clockSubscription.cancel();
    await _daypickerSubscription.cancel();
    await _memoplannerSettingsSubscription.cancel();
  }
}
