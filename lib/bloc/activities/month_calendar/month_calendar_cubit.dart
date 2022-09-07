import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'month_calendar_state.dart';

class MonthCalendarCubit extends Cubit<MonthCalendarState> {
  final ActivityRepository? activityRepository;
  final TimerCubit? timerCubit;
  final ClockBloc clockBloc;
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription? _activitiesSubscription;
  late final StreamSubscription? _timersSubscription;
  late final StreamSubscription _clockSubscription;

  MonthCalendarCubit({
    required this.clockBloc,
    required this.dayPickerBloc,
    this.activityRepository, // ActivityRepository is null when this bloc is used for date picking
    this.timerCubit,
    ActivitiesBloc?
        activitiesBloc, // ActivitiesBloc is null when this bloc is used for date picking
    DateTime? initialDay,
  }) : super(
          _mapToState(
            (initialDay ?? clockBloc.state).firstDayOfMonth(),
            [],
            [],
            clockBloc.state,
          ),
        ) {
    _activitiesSubscription = activitiesBloc?.stream.listen(_updateMonth);
    _timersSubscription = timerCubit?.stream.listen(_updateMonth);
    _clockSubscription = clockBloc.stream
        .where((time) =>
            state.weeks
                .expand((w) => w.days)
                .whereType<MonthDay>()
                .firstWhereOrNull((day) => day.isCurrent)
                ?.day
                .isAtSameDay(time) ==
            false)
        .listen(_updateMonth);
  }

  void initialize() {
    _updateMonth();
  }

  Future<void> goToNextMonth() async {
    _maybeGoToCurrentDay(state.firstDay.nextMonth());
    final first = state.firstDay.nextMonth();
    final last = first.nextMonth();
    emit(
      _mapToState(
        first,
        await activityRepository?.allBetween(first, last) ?? [],
        timerCubit?.state.timers ?? [],
        clockBloc.state,
      ),
    );
  }

  Future<void> goToPreviousMonth() async {
    _maybeGoToCurrentDay(state.firstDay.previousMonth());
    final first = state.firstDay.previousMonth();
    final last = first.nextMonth();
    emit(
      _mapToState(
        first,
        await activityRepository?.allBetween(first, last) ?? [],
        timerCubit?.state.timers ?? [],
        clockBloc.state,
      ),
    );
  }

  Future<void> goToCurrentMonth() async {
    dayPickerBloc.add(GoTo(day: clockBloc.state));
    final first = clockBloc.state.firstDayOfMonth();
    final last = first.nextMonth();
    emit(
      _mapToState(
        first,
        await activityRepository?.allBetween(first, last) ?? [],
        timerCubit?.state.timers ?? [],
        clockBloc.state,
      ),
    );
  }

  void _maybeGoToCurrentDay(DateTime newFirstDay) {
    if (newFirstDay.month == clockBloc.state.month &&
        newFirstDay.year == clockBloc.state.year) {
      dayPickerBloc.add(GoTo(day: clockBloc.state));
    }
  }

  Future<void> _updateMonth([_]) async {
    final first = state.firstDay;
    final last = first.nextMonth();
    emit(
      _mapToState(
        first,
        await activityRepository?.allBetween(first, last) ?? [],
        timerCubit?.state.timers ?? [],
        clockBloc.state,
      ),
    );
  }

  static MonthCalendarState _mapToState(
    DateTime firstDayOfMonth,
    Iterable<Activity> activities,
    Iterable<AbiliaTimer> timers,
    DateTime now,
  ) {
    assert(firstDayOfMonth.day == 1);
    assert(firstDayOfMonth.hour == 0);
    assert(firstDayOfMonth.minute == 0);
    assert(firstDayOfMonth.second == 0);
    assert(firstDayOfMonth.millisecond == 0);
    assert(firstDayOfMonth.microsecond == 0);

    final firstDayNextMonth = firstDayOfMonth.nextMonth();
    final month = firstDayOfMonth.month;

    var dayIterator = firstDayOfMonth.firstInWeek();
    final lastDay = dayIterator.addDays(6 * DateTime.daysPerWeek);
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
                _getDay(activities, timers, dayIterator, now)
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
    );
  }

  static MonthDay _getDay(
    Iterable<Activity> activities,
    Iterable<AbiliaTimer> timers,
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

    final hasTimers = timers.any((timer) => timer.startTime.isAtSameDay(day));

    if (activitiesThatDay.isEmpty) {
      return MonthDay(day, null, false, hasTimers, 0, occasion);
    }
    final fullDayActivity =
        activitiesThatDay.firstWhereOrNull((a) => a.activity.fullDay);
    final fullDayActivityCount =
        activitiesThatDay.where((a) => a.activity.fullDay).length;
    final hasActivities = activitiesThatDay.any((a) => !a.activity.fullDay);
    return MonthDay(
      day,
      fullDayActivity,
      hasActivities,
      hasTimers,
      fullDayActivityCount,
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
