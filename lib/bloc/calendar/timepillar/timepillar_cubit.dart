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
          true,
        )) {
    _streamSubscription = MergeStream([
      clockBloc.stream,
      memoSettingsBloc.stream,
      dayPickerBloc.stream,
      activitiesBloc.stream,
      timerAlarmBloc.stream,
    ]).listen(
      (streamState) => _onTimepillarConditionsChanged(
        showNightCalendar: streamState is DayPickerState &&
                !(streamState.lastEvent is NextDay ||
                    streamState.lastEvent is PreviousDay) ||
            state.showNightCalendar,
      ),
    );
  }

  void _onTimepillarConditionsChanged({required bool showNightCalendar}) {
    emit(
      _generateState(
        clockBloc.state,
        dayPickerBloc.state.day,
        memoSettingsBloc.state,
        activitiesBloc.state.activities,
        timerAlarmBloc.state.timers,
        showNightCalendar,
      ),
    );
  }

  static TimepillarState _generateState(
    DateTime now,
    DateTime selectedDay,
    MemoplannerSettingsState memoState,
    List<Activity> activities,
    List<TimerOccasion> timers,
    bool showNightCalendar,
  ) {
    final interval = _getInterval(
      now,
      selectedDay,
      memoState,
      showNightCalendar,
    );
    final occasion = interval.occasion(now);
    return TimepillarState(
      interval: interval,
      events: _generateEvents(
        occasion,
        activities,
        timers,
        interval,
      ),
      calendarType: _getCalendarType(
        showNightCalendar,
        memoState.dayCalendarType,
        selectedDay,
        now,
        memoState.settings.calendar.dayParts,
      ),
      occasion: interval.occasion(now),
      showNightCalendar: showNightCalendar,
    );
  }

  static TimepillarInterval _getInterval(
    DateTime now,
    DateTime day,
    MemoplannerSettingsState memoSettings,
    bool showNightCalendar,
  ) {
    final isToday = day.isAtSameDay(now);
    final twoTimepillars =
        memoSettings.dayCalendarType == DayCalendarType.twoTimepillars;

    if (twoTimepillars) {
      bool shouldShowNightCalendar = showNightCalendar &&
          isToday &&
          now.isNight(memoSettings.settings.calendar.dayParts);

      if (shouldShowNightCalendar) {
        return memoSettings.settings.calendar.dayParts
            .todayTimepillarIntervalFromType(
          now,
          TimepillarIntervalType.interval,
        );
      }

      return TimepillarInterval.dayAndNight(
        day.add(memoSettings.settings.calendar.dayParts.morningStart
            .milliseconds()),
      );
    }

    if (showNightCalendar && isToday) {
      return memoSettings.todayTimepillarInterval(now);
    }

    return TimepillarInterval.dayAndNight(day);
  }

  static List<Event> _generateEvents(
    Occasion occasion,
    List<Activity> activities,
    List<TimerOccasion> timers,
    TimepillarInterval interval,
  ) {
    final dayActivities = activities
        .where((a) => !a.fullDay)
        .expand((activity) => activity.dayActivitiesForInterval(interval))
        .removeAfterOccasion(occasion);

    final timerOccasions = timers.where(
      (timer) =>
          timer.start.inInclusiveRange(
            startDate: interval.start,
            endDate: interval.end,
          ) ||
          timer.end.inInclusiveRange(
            startDate: interval.start,
            endDate: interval.end,
          ),
    );
    return [...dayActivities, ...timerOccasions];
  }

  static DayCalendarType _getCalendarType(
    bool showNightCalendar,
    DayCalendarType settingsDayCalendarType,
    DateTime selectedDay,
    DateTime now,
    DayParts dayParts,
  ) {
    bool shouldShowNightCalendar = showNightCalendar &&
        settingsDayCalendarType == DayCalendarType.twoTimepillars &&
        _isTonight(day: selectedDay, now: now, dayParts: dayParts);
    return shouldShowNightCalendar
        ? DayCalendarType.oneTimepillar
        : settingsDayCalendarType;
  }

  static bool _isTonight({
    required DateTime day,
    required DateTime now,
    required DayParts dayParts,
  }) =>
      day.isAtSameDay(now) && now.isNight(dayParts);

  void next() {
    if (_shouldStepDay(forward: true)) {
      dayPickerBloc.add(NextDay());
    }
  }

  void previous() {
    if (_shouldStepDay(forward: false)) {
      dayPickerBloc.add(PreviousDay());
    }
  }

  bool _shouldStepDay({required bool forward}) {
    final memeSettings = memoSettingsBloc.state;

    if (memeSettings.dayCalendarType == DayCalendarType.list) return true;

    if (memeSettings.dayCalendarType == DayCalendarType.oneTimepillar &&
        memeSettings.timepillarIntervalType ==
            TimepillarIntervalType.dayAndNight) return true;

    if (!_isTonight(
      day: dayPickerBloc.state.day,
      now: clockBloc.state,
      dayParts: memeSettings.settings.calendar.dayParts,
    )) return true;

    final isBeforeMidNight = clockBloc.state
        .isNightBeforeMidnight(memeSettings.settings.calendar.dayParts);

    final beforeMidnightGoingForwardOrAfterMidnightGoingBack =
        (forward ? isBeforeMidNight : !isBeforeMidNight) ==
            state.showNightCalendar;

    if (beforeMidnightGoingForwardOrAfterMidnightGoingBack) return true;

    _onTimepillarConditionsChanged(showNightCalendar: !state.showNightCalendar);
    return false;
  }

  @override
  Future<void> close() async {
    await _streamSubscription.cancel();
    return super.close();
  }
}
