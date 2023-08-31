import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

part 'month_calendar_state.dart';

class MonthCalendarCubit extends Cubit<MonthCalendarState> {
  final ActivityRepository? activityRepository;
  final TimerAlarmBloc? timerAlarmBloc;
  final ClockCubit clockCubit;
  final DayPickerBloc dayPickerBloc;
  final SettingsDb? settingsDb;
  late final StreamSubscription? _activitiesSubscription;
  late final StreamSubscription? _timersSubscription;
  late final StreamSubscription _clockSubscription;

  bool get showPreview =>
      state.firstDay.month == dayPickerBloc.state.day.month &&
      state.firstDay.year == dayPickerBloc.state.day.year;

  MonthCalendarCubit({
    required this.clockCubit,
    required this.dayPickerBloc,
    this.activityRepository, // ActivityRepository is null when this bloc is used for date picking
    this.timerAlarmBloc,
    this.settingsDb,
    ActivitiesCubit?
        activitiesCubit, // ActivitiesCubit is null when this bloc is used for date picking
    DateTime? initialDay,
  }) : super(
          MonthCalendarState(
            firstDay: clockCubit.state,
            occasion: Occasion.current,
            weeks: [],
            isCollapsed: true,
          ),
        ) {
    _activitiesSubscription = activitiesCubit?.stream.listen(updateMonth);
    _timersSubscription = timerAlarmBloc?.stream.listen(updateMonth);
    _clockSubscription = clockCubit.stream
        .where((time) =>
            state.weeks
                .expand((w) => w.days)
                .whereType<MonthDay>()
                .firstWhereOrNull((day) => day.isCurrent)
                ?.day
                .isAtSameDay(time) ==
            false)
        .listen(updateMonth);
    emit(
      _mapToState(
        (initialDay ?? clockCubit.state).firstDayOfMonth(),
        [],
        [],
        clockCubit.state,
      ),
    );
  }

  Future<void> goToNextMonth() async {
    _maybeGoToCurrentDay(state.firstDay.nextMonth());
    final first = state.firstDay.nextMonth();
    final last = first.nextMonth();
    final activities = await activityRepository?.allBetween(first, last) ?? [];
    if (isClosed) return;
    emit(
      _mapToState(
        first,
        activities,
        timerAlarmBloc?.state.timers ?? [],
        clockCubit.state,
        true,
      ),
    );
  }

  Future<void> goToPreviousMonth() async {
    _maybeGoToCurrentDay(state.firstDay.previousMonth());
    final first = state.firstDay.previousMonth();
    final last = first.nextMonth();
    final activities = await activityRepository?.allBetween(first, last) ?? [];
    if (isClosed) return;
    emit(
      _mapToState(
        first,
        activities,
        timerAlarmBloc?.state.timers ?? [],
        clockCubit.state,
        true,
      ),
    );
  }

  Future<void> goToCurrentMonth() async {
    dayPickerBloc.add(GoTo(day: clockCubit.state));
    final first = clockCubit.state.firstDayOfMonth();
    final last = first.nextMonth();
    final activities = await activityRepository?.allBetween(first, last) ?? [];
    if (isClosed) return;
    emit(
      _mapToState(
        first,
        activities,
        timerAlarmBloc?.state.timers ?? [],
        clockCubit.state,
        true,
      ),
    );
  }

  void _maybeGoToCurrentDay(DateTime newFirstDay) {
    if (newFirstDay.month == clockCubit.state.month &&
        newFirstDay.year == clockCubit.state.year) {
      dayPickerBloc.add(GoTo(day: clockCubit.state));
    }
  }

  Future<void> updateMonth([_]) async {
    final first = state.firstDay;
    final last = first.nextMonth();
    final activities = await activityRepository?.allBetween(first, last) ?? [];
    if (isClosed) return;
    emit(
      _mapToState(
        first,
        activities,
        timerAlarmBloc?.state.timers ?? [],
        clockCubit.state,
      ),
    );
  }

  void toggleCollapsed() => setCollapsed(!state.isCollapsed);

  void setCollapsed(bool isCollapsed) =>
      emit(state.copyWith(isCollapsed: isCollapsed));

  MonthCalendarState _mapToState(
    DateTime firstDayOfMonth,
    Iterable<Activity> activities,
    Iterable<TimerOccasion> timerOccasions,
    DateTime now, [
    bool? isCollapsed,
  ]) {
    assert(firstDayOfMonth.day == 1);
    assert(firstDayOfMonth.hour == 0);
    assert(firstDayOfMonth.minute == 0);
    assert(firstDayOfMonth.second == 0);
    assert(firstDayOfMonth.millisecond == 0);
    assert(firstDayOfMonth.microsecond == 0);

    final firstDayNextMonth = firstDayOfMonth.nextMonth();
    final month = firstDayOfMonth.month;

    var dayIterator = firstDayOfMonth.firstInWeek();
    final lastDay = firstDayOfMonth.lastDayOfMonth().lastInWeek();
    final weekData = [
      for (int week = firstDayOfMonth.getWeekNumber();
          dayIterator.isBefore(lastDay);
          week = dayIterator.getWeekNumber())
        MonthWeek(
          week,
          [
            for (int d = 0;
                d < DateTime.daysPerWeek;
                dayIterator = dayIterator.nextDay(), d++)
              if (dayIterator.month == month)
                _getDay(activities, timerOccasions, dayIterator, now)
              else
                NotInMonthDay()
          ],
        ),
    ];
    final occasion = now.isBefore(firstDayOfMonth)
        ? Occasion.future
        : firstDayNextMonth.isBefore(now)
            ? Occasion.past
            : Occasion.current;

    return MonthCalendarState(
      firstDay: firstDayOfMonth,
      occasion: occasion,
      weeks: weekData,
      isCollapsed: isCollapsed ?? state.isCollapsed,
    );
  }

  static MonthDay _getDay(
    Iterable<Activity> activities,
    Iterable<TimerOccasion> timerOccasions,
    DateTime day,
    DateTime now,
  ) {
    final occasion = day.isAtSameMomentOrAfter(now)
        ? Occasion.future
        : now.onlyDays().isAfter(day)
            ? Occasion.past
            : Occasion.current;

    final activitiesThatDay = activities
        .expand((activity) => activity.dayActivitiesForDay(day))
        .removeAfter(now)
        .toList();

    final hasTimer = timerOccasions.onDay(day).isNotEmpty;

    if (activitiesThatDay.isEmpty) {
      return MonthDay(day, null, hasTimer, 0, occasion);
    }
    final mapByFullDay = activitiesThatDay
        .groupListsBy((activityDay) => activityDay.activity.fullDay);
    final fullDayActivities = mapByFullDay[true] ?? [];
    final noneFullDayActivities = mapByFullDay[false] ?? [];
    final hasEvent = hasTimer || noneFullDayActivities.isNotEmpty;
    return MonthDay(
      day,
      fullDayActivities.firstOrNull,
      hasEvent,
      fullDayActivities.length,
      occasion,
    );
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription?.cancel();
    await _timersSubscription?.cancel();
    await _clockSubscription.cancel();
    return super.close();
  }
}
