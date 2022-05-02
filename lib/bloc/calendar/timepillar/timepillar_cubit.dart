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
  bool forceFullDay = false;

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
    _clockSubscription = clockBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _memoSettingsSubscription = memoSettingsBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _dayPickerSubscription = dayPickerBloc.stream.listen((state) {
      if (!state.lastEventStepEvent) forceFullDay = false;
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
    emit(_generateState(
      clockBloc.state,
      dayPickerBloc.state.day,
      memoSettingsBloc.state,
      activitiesBloc.state.activities,
      timerAlarmBloc.state.timers,
      forceFullDay,
    ));
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
    );
  }

  static TimepillarInterval generateInterval(DateTime now, DateTime day,
      MemoplannerSettingsState memoSettings, bool forceFullDay) {
    final isToday = day.isAtSameDay(now);
    final isNight = now.isNight(memoSettings.dayParts);
    if (memoSettings.dayCalendarType == DayCalendarType.twoTimepillars &&
        isToday &&
        isNight &&
        !forceFullDay) {
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
    return isToday && !forceFullDay
        ? memoSettings.todayTimepillarInterval(now)
        : TimepillarInterval(
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
    if (todayNight) {
      final nightBeforeMidnight = now.isNightBeforeMidnight(dayParts);
      if (!forceFullDay && !nightBeforeMidnight) {
        forceFullDay = true;
        return _onTimepillarConditionsChanged();
      } else if (forceFullDay && nightBeforeMidnight) {
        forceFullDay = false;
        return _onTimepillarConditionsChanged();
      }
    }
    dayPickerBloc.add(NextDay());
  }

  void previous() {
    final now = clockBloc.state;
    final dayParts = memoSettingsBloc.state.dayParts;
    final todayNight =
        dayPickerBloc.state.day.isAtSameDay(now) && now.isNight(dayParts);
    if (todayNight) {
      final nightBeforeMidnight = now.isNightBeforeMidnight(dayParts);
      if (forceFullDay && !nightBeforeMidnight) {
        forceFullDay = false;
        return _onTimepillarConditionsChanged();
      } else if (!forceFullDay && nightBeforeMidnight) {
        forceFullDay = true;
        return _onTimepillarConditionsChanged();
      }
    }
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
