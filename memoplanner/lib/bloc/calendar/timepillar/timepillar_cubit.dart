import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:rxdart/rxdart.dart';

part 'timepillar_interval_calculator.dart';
part 'timepillar_state.dart';

class TimepillarCubit extends Cubit<TimepillarState> {
  final ClockBloc clockBloc;
  final MemoplannerSettingsBloc memoSettingsBloc;
  final DayPickerBloc dayPickerBloc;
  final ActivitiesBloc activitiesBloc;
  final TimerAlarmBloc timerAlarmBloc;
  final DayPartCubit dayPartCubit;
  late StreamSubscription _streamSubscription;

  // Makes animated page transitions possible in DayCalendar
  late TimepillarState previousState = state;

  TimepillarCubit({
    required this.clockBloc,
    required this.memoSettingsBloc,
    required this.dayPickerBloc,
    required this.timerAlarmBloc,
    required this.activitiesBloc,
    required this.dayPartCubit,
  }) : super(_initialEmptyState(
          clockBloc.state,
          dayPickerBloc.state.day,
          memoSettingsBloc.state,
          timerAlarmBloc.state.timers,
          true,
          dayPartCubit.state,
        )) {
    _streamSubscription = MergeStream([
      clockBloc.stream,
      memoSettingsBloc.stream,
      dayPickerBloc.stream,
      activitiesBloc.stream,
      timerAlarmBloc.stream,
    ]).listen(
      (streamState) async => _onTimepillarConditionsChanged(
        showNightCalendar: streamState is DayPickerState &&
                !(streamState.lastEvent is NextDay ||
                    streamState.lastEvent is PreviousDay) ||
            state.showNightCalendar,
      ),
    );
  }

  Future<void> initialize() => _onTimepillarConditionsChanged(
      showNightCalendar: state.showNightCalendar);

  Future<void> _onTimepillarConditionsChanged(
      {required bool showNightCalendar}) async {
    final interval = _getInterval(
      clockBloc.state,
      dayPickerBloc.state.day,
      memoSettingsBloc.state,
      showNightCalendar,
      dayPartCubit.state,
    );
    final activities = await activitiesBloc.activityRepository
        .allBetween(interval.start.onlyDays(), interval.end);
    previousState = state;
    if (isClosed) return;
    emit(
      _generateState(
        clockBloc.state,
        dayPickerBloc.state.day,
        memoSettingsBloc.state,
        activities,
        timerAlarmBloc.state.timers,
        showNightCalendar,
        dayPartCubit.state,
      ),
    );
  }

  static TimepillarState _initialEmptyState(
    DateTime now,
    DateTime selectedDay,
    MemoplannerSettings settings,
    List<TimerOccasion> timers,
    bool showNightCalendar,
    DayPart dayPart,
  ) {
    return _generateState(
      now,
      selectedDay,
      settings,
      [],
      timers,
      showNightCalendar,
      dayPart,
    );
  }

  static TimepillarState _generateState(
    DateTime now,
    DateTime selectedDay,
    MemoplannerSettings settings,
    Iterable<Activity> activities,
    List<TimerOccasion> timers,
    bool showNightCalendar,
    DayPart dayPart,
  ) {
    final interval = _getInterval(
      now,
      selectedDay,
      settings,
      showNightCalendar,
      dayPart,
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
        settings.dayCalendar.viewOptions.calendarType,
        selectedDay,
        now,
        dayPart,
      ),
      occasion: interval.occasion(now),
      showNightCalendar: showNightCalendar,
      day: selectedDay,
    );
  }

  static TimepillarInterval _getInterval(
    DateTime now,
    DateTime day,
    MemoplannerSettings settings,
    bool showNightCalendar,
    DayPart dayPart,
  ) {
    final isToday = day.isAtSameDay(now);
    final twoTimepillars = settings.dayCalendar.viewOptions.calendarType ==
        DayCalendarType.twoTimepillars;

    if (twoTimepillars) {
      final shouldShowNightCalendar =
          showNightCalendar && isToday && dayPart.isNight;

      if (shouldShowNightCalendar) {
        return _todayTimepillarIntervalFromType(
          now,
          TimepillarIntervalType.interval,
          settings.calendar.dayParts,
          dayPart,
        );
      }

      return TimepillarInterval.dayAndNight(
        day.add(settings.calendar.dayParts.morning),
      );
    }

    if (showNightCalendar && isToday) {
      return _todayTimepillarIntervalFromType(
        now,
        settings.dayCalendar.viewOptions.intervalType,
        settings.calendar.dayParts,
        dayPart,
      );
    }

    return TimepillarInterval.dayAndNight(day);
  }

  static List<Event> _generateEvents(
    Occasion occasion,
    Iterable<Activity> activities,
    List<TimerOccasion> timers,
    TimepillarInterval interval,
  ) {
    final dayActivities = activities
        .where((a) => !a.fullDay)
        .expand((activity) => activity.dayActivitiesForInterval(interval))
        .removeAfterOccasion(occasion)
        .toSet();

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
    DayPart dayPart,
  ) {
    final shouldShowNightCalendar = showNightCalendar &&
        settingsDayCalendarType == DayCalendarType.twoTimepillars &&
        _isTonight(day: selectedDay, now: now, dayPart: dayPart);
    return shouldShowNightCalendar
        ? DayCalendarType.oneTimepillar
        : settingsDayCalendarType;
  }

  static bool _isTonight({
    required DateTime day,
    required DateTime now,
    required DayPart dayPart,
  }) =>
      day.isAtSameDay(now) && dayPart.isNight;

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

  bool maybeGoToNightCalendar() {
    if (_shouldGoToNightCalendar) {
      unawaited(_onTimepillarConditionsChanged(showNightCalendar: true));
      return true;
    }
    return false;
  }

  bool get _shouldGoToNightCalendar {
    final settings = memoSettingsBloc.state;
    final viewOptions = settings.dayCalendar.viewOptions;
    final isToday = dayPickerBloc.state.isToday;
    final isList = viewOptions.calendarType == DayCalendarType.list;
    final showingNightCalendar = state.showNightCalendar;
    final isDayAndNight =
        viewOptions.calendarType == DayCalendarType.oneTimepillar &&
            viewOptions.intervalType == TimepillarIntervalType.dayAndNight;
    final isNight = clockBloc.state.isNight(settings.calendar.dayParts);

    return isToday &&
        !isList &&
        !isDayAndNight &&
        isNight &&
        !showingNightCalendar;
  }

  bool _shouldStepDay({required bool forward}) {
    final settings = memoSettingsBloc.state;
    final viewOptions = settings.dayCalendar.viewOptions;

    if (viewOptions.calendarType == DayCalendarType.list) {
      return true;
    }

    if (viewOptions.calendarType == DayCalendarType.oneTimepillar &&
        viewOptions.intervalType == TimepillarIntervalType.dayAndNight) {
      return true;
    }

    if (!_isTonight(
      day: dayPickerBloc.state.day,
      now: clockBloc.state,
      dayPart: dayPartCubit.state,
    )) return true;

    final isBeforeMidNight =
        clockBloc.state.isNightBeforeMidnight(settings.calendar.dayParts);

    final beforeMidnightGoingForwardOrAfterMidnightGoingBack =
        (forward ? isBeforeMidNight : !isBeforeMidNight) ==
            state.showNightCalendar;

    if (beforeMidnightGoingForwardOrAfterMidnightGoingBack) return true;

    unawaited(_onTimepillarConditionsChanged(
      showNightCalendar: !state.showNightCalendar,
    ));
    return false;
  }

  @override
  Future<void> close() async {
    await _streamSubscription.cancel();
    return super.close();
  }
}
