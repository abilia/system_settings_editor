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
  final DayCalendarViewCubit dayCalendarViewCubit;
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
    required this.dayCalendarViewCubit,
    required this.dayPickerBloc,
    required this.timerAlarmBloc,
    required this.activitiesBloc,
    required this.dayPartCubit,
  }) : super(_initialEmptyState(
          now: clockBloc.state,
          selectedDay: dayPickerBloc.state.day,
          memoplannerSettings: memoSettingsBloc.state,
          dayCalendarViewOptionsSettings: dayCalendarViewCubit.state,
          timers: timerAlarmBloc.state.timers,
          showNightCalendar: true,
          dayPart: dayPartCubit.state,
        )) {
    _streamSubscription = MergeStream([
      clockBloc.stream,
      memoSettingsBloc.stream,
      dayPickerBloc.stream,
      activitiesBloc.stream,
      timerAlarmBloc.stream,
      dayCalendarViewCubit.stream,
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
      now: clockBloc.state,
      day: dayPickerBloc.state.day,
      calendarSettings: memoSettingsBloc.state.calendar,
      showNightCalendar: showNightCalendar,
      dayCalendarViewOptions: dayCalendarViewCubit.state,
      dayPart: dayPartCubit.state,
    );
    final activities = await activitiesBloc.activityRepository
        .allBetween(interval.start.onlyDays(), interval.end);
    previousState = state;
    if (isClosed) return;
    emit(
      _generateState(
        now: clockBloc.state,
        selectedDay: dayPickerBloc.state.day,
        memoplannerSettings: memoSettingsBloc.state,
        dayCalendarViewOptionsSettings: dayCalendarViewCubit.state,
        activities: activities,
        timers: timerAlarmBloc.state.timers,
        showNightCalendar: showNightCalendar,
        dayPart: dayPartCubit.state,
      ),
    );
  }

  static TimepillarState _initialEmptyState({
    required DateTime now,
    required DateTime selectedDay,
    required MemoplannerSettings memoplannerSettings,
    required DayCalendarViewSettings dayCalendarViewOptionsSettings,
    required List<TimerOccasion> timers,
    required bool showNightCalendar,
    required DayPart dayPart,
  }) {
    return _generateState(
      now: now,
      selectedDay: selectedDay,
      memoplannerSettings: memoplannerSettings,
      dayCalendarViewOptionsSettings: dayCalendarViewOptionsSettings,
      activities: [],
      timers: timers,
      showNightCalendar: showNightCalendar,
      dayPart: dayPart,
    );
  }

  static TimepillarState _generateState({
    required DateTime now,
    required DateTime selectedDay,
    required MemoplannerSettings memoplannerSettings,
    required DayCalendarViewSettings dayCalendarViewOptionsSettings,
    required Iterable<Activity> activities,
    required List<TimerOccasion> timers,
    required bool showNightCalendar,
    required DayPart dayPart,
  }) {
    final interval = _getInterval(
      now: now,
      day: selectedDay,
      calendarSettings: memoplannerSettings.calendar,
      dayCalendarViewOptions: dayCalendarViewOptionsSettings,
      showNightCalendar: showNightCalendar,
      dayPart: dayPart,
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
        dayCalendarViewOptionsSettings.calendarType,
        selectedDay,
        now,
        dayPart,
      ),
      occasion: interval.occasion(now),
      showNightCalendar: showNightCalendar,
      day: selectedDay,
    );
  }

  static TimepillarInterval _getInterval({
    required DateTime now,
    required DateTime day,
    required GeneralCalendarSettings calendarSettings,
    required DayCalendarViewSettings dayCalendarViewOptions,
    required bool showNightCalendar,
    required DayPart dayPart,
  }) {
    final isToday = day.isAtSameDay(now);
    final twoTimepillars =
        dayCalendarViewOptions.calendarType == DayCalendarType.twoTimepillars;

    if (twoTimepillars) {
      final shouldShowNightCalendar =
          showNightCalendar && isToday && dayPart.isNight;

      if (shouldShowNightCalendar) {
        return _todayTimepillarIntervalFromType(
          now,
          TimepillarIntervalType.interval,
          calendarSettings.dayParts,
          dayPart,
        );
      }

      return TimepillarInterval.dayAndNight(
        day.add(calendarSettings.dayParts.morning),
      );
    }

    if (showNightCalendar && isToday) {
      return _todayTimepillarIntervalFromType(
        now,
        dayCalendarViewOptions.intervalType,
        calendarSettings.dayParts,
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
    final seen = <int>{};
    final dayActivities = activities
        .where((a) => !a.fullDay)
        .expand((activity) => dayActivitiesForInterval(activity, interval))
        .removeAfterOccasion(occasion)
        .where(
          (activity) => seen.add(activity.id.hashCode ^ activity.day.hashCode),
        );
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

  static List<ActivityDay> dayActivitiesForInterval(
    Activity activity,
    TimepillarInterval interval,
  ) =>
      List.generate(
        interval.daySpan,
        interval.start.onlyDays().addDays,
      ).expand(activity.dayActivitiesForDay).toList();

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
    final viewOptions = dayCalendarViewCubit.state;
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
    final viewOptions = dayCalendarViewCubit.state;

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
