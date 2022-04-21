import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';

part 'timepillar_state.dart';

class TimepillarCubit extends Cubit<TimepillarState> {
  /// All fields are null when timepillarCubit is fixed
  /// in Timepillar settings (`PreviewTimePillar`), or `TwoTimepillarCalendar`
  final ClockBloc? clockBloc;
  final MemoplannerSettingBloc? memoSettingsBloc;
  final DayPickerBloc? dayPickerBloc;
  final ActivitiesBloc? activitiesBloc;
  final TimerAlarmBloc? timerAlarmBloc;
  StreamSubscription? _clockSubscription;
  StreamSubscription? _memoSettingsSubscription;
  StreamSubscription? _dayPickerSubscription;
  StreamSubscription? _activitiesSubscription;
  StreamSubscription? _timerSubscription;

  // ignore_for_file: prefer_initializing_formals
  TimepillarCubit({
    required ClockBloc clockBloc,
    required MemoplannerSettingBloc memoSettingsBloc,
    required DayPickerBloc dayPickerBloc,
    required TimerAlarmBloc timerAlarmBloc,
    required ActivitiesBloc activitiesBloc,
  })  : clockBloc = clockBloc,
        memoSettingsBloc = memoSettingsBloc,
        dayPickerBloc = dayPickerBloc,
        activitiesBloc = activitiesBloc,
        timerAlarmBloc = timerAlarmBloc,
        super(_generateState(
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

  TimepillarCubit.fixed({
    this.clockBloc,
    this.memoSettingsBloc,
    this.dayPickerBloc,
    this.activitiesBloc,
    this.timerAlarmBloc,
    required TimepillarState state,
  }) : super(state);

  void _onTimepillarConditionsChanged() {
    final time = clockBloc?.state;
    final day = dayPickerBloc?.state.day;
    final settings = memoSettingsBloc?.state;
    if (time != null && day != null && settings != null) {
      final activities = activitiesBloc?.state.activities ?? [];
      final timers = timerAlarmBloc?.state.timers ?? <TimerOccasion>[];
      emit(_generateState(
        time,
        day,
        settings,
        activities,
        timers,
      ));
    }
  }

  static TimepillarState _generateState(
      DateTime state,
      DateTime day,
      MemoplannerSettingsState memoState,
      List<Activity> activities,
      List<TimerOccasion> timers) {
    return TimepillarState(
      generateInterval(state, day, memoState),
      memoState.dayCalendarType == DayCalendarType.twoTimepillars
          ? TimepillarZoom.small.zoomValue
          : memoState.timepillarZoom.zoomValue,
      generateEvents(
        activities,
        timers,
        generateInterval(state, day, memoState),
      ),
      DayCalendarType.oneTimepillar,
    );
  }

  static TimepillarInterval generateInterval(
      DateTime now, DateTime day, MemoplannerSettingsState memoSettings) {
    final isToday = day.isAtSameDay(now);
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
    dayPickerBloc?.add(NextDay());
  }

  void previous() {
    dayPickerBloc?.add(PreviousDay());
  }

  @override
  Future<void> close() async {
    await _clockSubscription?.cancel();
    await _memoSettingsSubscription?.cancel();
    await _dayPickerSubscription?.cancel();
    await _timerSubscription?.cancel();
    await _activitiesSubscription?.cancel();
    return super.close();
  }
}
