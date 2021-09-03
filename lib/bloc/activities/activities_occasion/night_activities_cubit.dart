import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class NightActivitiesCubit extends Cubit<ActivitiesOccasionLoaded> {
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
    _activitiesSubscription = activitiesBloc.stream.listen((_) => _newState());
    _daypickerSubscription = dayPickerBloc.stream.listen((_) => _newState());
    _memoplannerSettingsSubscription = memoplannerSettingBloc.stream
        .where((settingsState) => settingsState.dayParts != _dayParts)
        .listen((settingsState) {
      _dayParts = settingsState.dayParts;
      _newState();
    });
  }

  void _newState() => emit(
        _stateFromActivities(
          activitiesBloc.state.activities,
          dayPickerBloc.state.day,
          clockBloc.state,
          memoplannerSettingBloc.state.dayParts,
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

  static ActivitiesOccasionLoaded _stateFromActivities(
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

  static ActivitiesOccasionLoaded _stateFromActivityDays(
    List<ActivityDay> dayActivities,
    DateTime day,
    DateTime now,
    DayParts dayParts,
  ) =>
      mapActivitiesToActivityOccasionsState(
        dayActivities: dayActivities,
        day: day,
        now: now,
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
