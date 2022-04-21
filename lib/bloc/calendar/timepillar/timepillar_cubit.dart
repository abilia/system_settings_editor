import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';

part 'timepillar_state.dart';

class TimepillarCubit extends Cubit<TimepillarState> {
  final ClockBloc clockBloc;
  final MemoplannerSettingBloc memoSettingsBloc;
  final DayPickerBloc dayPickerBloc;
  final ActivitiesBloc activitiesBloc;
  final TimerAlarmBloc timerAlarmBloc;
  late StreamSubscription _clockSubscription;
  late StreamSubscription _memoSettingsSubscription;
  late StreamSubscription _dayPickerSubscription;
  late StreamSubscription _activitiesSubscription;
  late StreamSubscription _timerSubscription;

  // ignore_for_file: prefer_initializing_formals
  TimepillarCubit({
    required this.clockBloc,
    required this.memoSettingsBloc,
    required this.dayPickerBloc,
    required this.timerAlarmBloc,
    required this.activitiesBloc,
  }) : super(_generateState(
          clockBloc.state,
          dayPickerBloc.state.day,
          memoSettingsBloc.state,
          activitiesBloc.state.activities,
          timerAlarmBloc.state.timers,
        )) {
    _clockSubscription = clockBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _memoSettingsSubscription = memoSettingsBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _dayPickerSubscription = dayPickerBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _timerSubscription = timerAlarmBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _activitiesSubscription = activitiesBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
  }

  void _onTimepillarConditionsChanged() {
    final time = clockBloc.state;
    final day = dayPickerBloc.state.day;
    final settings = memoSettingsBloc.state;
    final activities = activitiesBloc.state.activities;
    final timers = timerAlarmBloc.state.timers;
    emit(_generateState(
      time,
      day,
      settings,
      activities,
      timers,
    ));
  }

  static TimepillarState _generateState(
      DateTime now,
      DateTime selectedDay,
      MemoplannerSettingsState memoState,
      List<Activity> activities,
      List<TimerOccasion> timers) {
    final interval = generateInterval(now, selectedDay, memoState);
    final todayNight =
        selectedDay.isAtSameDay(now) && now.isNight(memoState.dayParts);
    return TimepillarState(
      interval,
      generateEvents(
        activities,
        timers,
        interval,
      ),
      memoState.dayCalendarType == DayCalendarType.twoTimepillars && todayNight
          ? DayCalendarType.oneTimepillar
          : memoState.dayCalendarType,
    );
  }

  static TimepillarInterval generateInterval(
      DateTime now, DateTime day, MemoplannerSettingsState memoSettings) {
    final isToday = day.isAtSameDay(now);
    final isNight = now.isNight(memoSettings.dayParts);
    if (memoSettings.dayCalendarType == DayCalendarType.twoTimepillars &&
        isToday &&
        isNight) {
      return memoSettings.todayTimepillarIntervalFromType(
          now, TimepillarIntervalType.interval);
    }
    if (memoSettings.dayCalendarType == DayCalendarType.twoTimepillars) {
      final intervalStart =
          day.add(memoSettings.dayParts.morningStart.milliseconds());
      final intervalEnd = intervalStart.addDays(1);
      return TimepillarInterval(
          start: intervalStart,
          end: intervalEnd,
          intervalPart: IntervalPart.dayAndNight);
    }
    return isToday
        ? memoSettings.todayTimepillarInterval(now)
        : TimepillarInterval(
            start: day.onlyDays(),
            end: day.onlyDays().add(1.days()),
            intervalPart: IntervalPart.dayAndNight,
          );
  }

  static List<Event> generateEvents(List<Activity> activities,
      List<TimerOccasion> timers, TimepillarInterval interval) {
    // First do a fast filter
    final dayActivities = activities
        .expand((activity) => activity.dayActivitiesForInterval(
            interval.startTime, interval.endTime))
        .toList();
    final timerOccasions = timers
        .where((timer) =>
            timer.start.inInclusiveRange(
                startDate: interval.startTime, endDate: interval.endTime) ||
            timer.end.inInclusiveRange(
                startDate: interval.startTime, endDate: interval.endTime))
        .toList();
    return {...dayActivities, ...timerOccasions}.toList();
  }

  void next() {
    dayPickerBloc.add(NextDay());
  }

  void previous() {
    dayPickerBloc.add(PreviousDay());
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    await _memoSettingsSubscription.cancel();
    await _dayPickerSubscription.cancel();
    await _timerSubscription.cancel();
    await _activitiesSubscription.cancel();
    return super.close();
  }
}
