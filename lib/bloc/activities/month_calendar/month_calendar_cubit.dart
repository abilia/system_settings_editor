import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'month_calendar_state.dart';

class MonthCalendarCubit extends Cubit<MonthCalendarState> {
  /// ActivitiesBloc is null when this bloc is used for date picking
  final ActivitiesBloc? activitiesBloc;
  final ClockBloc clockBloc;
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription? _activitiesSubscription;
  late final StreamSubscription _clockSubscription;

  MonthCalendarCubit({
    this.activitiesBloc,
    required this.clockBloc,
    required this.dayPickerBloc,
    DateTime? initialDay,
  }) : super(
          _mapToState(
            (initialDay ?? clockBloc.state).firstDayOfMonth(),
            activitiesBloc?.state.activities,
            clockBloc.state,
          ),
        ) {
    _activitiesSubscription = activitiesBloc?.stream.listen(_updateMonth);
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

  void goToNextMonth() {
    _maybeGoToCurrentDay(state.firstDay.nextMonth());
    emit(
      _mapToState(
        state.firstDay.nextMonth(),
        activitiesBloc?.state.activities,
        clockBloc.state,
      ),
    );
  }

  void goToPreviousMonth() {
    _maybeGoToCurrentDay(state.firstDay.previousMonth());
    emit(
      _mapToState(
        state.firstDay.previousMonth(),
        activitiesBloc?.state.activities,
        clockBloc.state,
      ),
    );
  }

  void goToCurrentMonth() {
    dayPickerBloc.add(GoTo(day: clockBloc.state));
    emit(
      _mapToState(
        clockBloc.state.firstDayOfMonth(),
        activitiesBloc?.state.activities,
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

  void _updateMonth([_]) => emit(
        _mapToState(
          state.firstDay,
          activitiesBloc?.state.activities,
          clockBloc.state,
        ),
      );

  static MonthCalendarState _mapToState(
    DateTime firstDayOfMonth,
    Iterable<Activity>? activities,
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
                _getDay(activities ?? [], dayIterator, now)
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
      Iterable<Activity> activities, DateTime day, DateTime now) {
    final occasion = day.isAtSameMomentOrAfter(now)
        ? Occasion.future
        : now.onlyDays().isAfter(day)
            ? Occasion.past
            : Occasion.current;

    final activitiesThatDay = activities
        .expand((activity) => activity.dayActivitiesForDay(day))
        .removeAfter(now)
        .toList();
    if (activitiesThatDay.isEmpty) {
      return MonthDay(day, null, false, 0, occasion);
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
      fullDayActivityCount,
      occasion,
    );
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription?.cancel();
    await _clockSubscription.cancel();
    return super.close();
  }
}
