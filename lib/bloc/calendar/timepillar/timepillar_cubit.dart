import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

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
  late StreamSubscription _streamSubscription;

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
          false,
        )) {
    _streamSubscription = MergeStream([
      clockBloc.stream,
      memoSettingsBloc.stream,
      dayPickerBloc.stream,
      timerAlarmBloc.stream,
      activitiesBloc.stream,
    ]).listen((streamState) {
      if (streamState is DayPickerState && !streamState.lastEventStepEvent) {
        return _onTimepillarConditionsChanged(forceFullDay: false);
      }
      _onTimepillarConditionsChanged(forceFullDay: state.forceFullDay);
    });
  }

  void _onTimepillarConditionsChanged({required bool forceFullDay}) {
    emit(
      _generateState(
        clockBloc.state,
        dayPickerBloc.state.day,
        memoSettingsBloc.state,
        activitiesBloc.state.activities,
        timerAlarmBloc.state.timers,
        forceFullDay,
      ),
    );
  }

  static TimepillarState _generateState(
    DateTime now,
    DateTime selectedDay,
    MemoplannerSettingsState memoState,
    List<Activity> activities,
    List<TimerOccasion> timers,
    bool forceFullDay,
  ) {
    final interval =
        generateInterval(now, selectedDay, memoState, forceFullDay);
    final todayNight =
        selectedDay.isAtSameDay(now) && now.isNight(memoState.dayParts);
    final occasion = now.isBefore(interval.startTime)
        ? Occasion.future
        : now.isAfter(interval.endTime)
            ? Occasion.past
            : Occasion.current;
    return TimepillarState(
      interval,
      generateEvents(
        activities,
        timers,
        interval,
      ),
      memoState.dayCalendarType == DayCalendarType.twoTimepillars &&
              todayNight &&
              !forceFullDay
          ? DayCalendarType.oneTimepillar
          : memoState.dayCalendarType,
      occasion,
      forceFullDay,
    );
  }

  static TimepillarInterval generateInterval(
    DateTime now,
    DateTime day,
    MemoplannerSettingsState memoSettings,
    bool forceFullDay,
  ) {
    final isTodayAndNotForceFullDay = day.isAtSameDay(now) && !forceFullDay;
    final twoTimepillars =
        memoSettings.dayCalendarType == DayCalendarType.twoTimepillars;

    if (twoTimepillars) {
      if (isTodayAndNotForceFullDay && now.isNight(memoSettings.dayParts)) {
        return memoSettings.todayTimepillarIntervalFromType(
          now,
          TimepillarIntervalType.interval,
        );
      }

      final intervalStart =
          day.add(memoSettings.dayParts.morningStart.milliseconds());
      final intervalEnd = intervalStart.addDays(1);
      return TimepillarInterval(
        start: intervalStart,
        end: intervalEnd,
        intervalPart: IntervalPart.dayAndNight,
      );
    }

    if (isTodayAndNotForceFullDay) {
      return memoSettings.todayTimepillarInterval(now);
    }

    return TimepillarInterval(
      start: day.onlyDays(),
      end: day.onlyDays().add(1.days()),
      intervalPart: IntervalPart.dayAndNight,
    );
  }

  static List<Event> generateEvents(List<Activity> activities,
      List<TimerOccasion> timers, TimepillarInterval interval) {
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
    final now = clockBloc.state;
    final dayParts = memoSettingsBloc.state.dayParts;
    final todayNight =
        dayPickerBloc.state.day.isAtSameDay(now) && now.isNight(dayParts);
    final isNightBeforeMidnight = now.isNightBeforeMidnight(dayParts);
    if (todayNight && state.forceFullDay == isNightBeforeMidnight) {
      return _onTimepillarConditionsChanged(forceFullDay: !state.forceFullDay);
    }
    dayPickerBloc.add(NextDay());
  }

  void previous() {
    final now = clockBloc.state;
    final dayParts = memoSettingsBloc.state.dayParts;
    final todayNight =
        dayPickerBloc.state.day.isAtSameDay(now) && now.isNight(dayParts);
    final nightBeforeMidnight = now.isNightBeforeMidnight(dayParts);
    if (todayNight && state.forceFullDay != nightBeforeMidnight) {
      return _onTimepillarConditionsChanged(forceFullDay: !state.forceFullDay);
    }
    dayPickerBloc.add(PreviousDay());
  }

  @override
  Future<void> close() async {
    await _streamSubscription.cancel();
    return super.close();
  }
}
