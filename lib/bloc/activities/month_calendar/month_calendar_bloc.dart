import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'month_calendar_event.dart';
part 'month_calendar_state.dart';

class MonthCalendarBloc extends Bloc<MonthCalendarEvent, MonthCalendarState> {
  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  StreamSubscription _activitiesSubscription;
  StreamSubscription _clockSubscription;

  MonthCalendarBloc({
    this.activitiesBloc,
    this.clockBloc,
  }) : super(
          _mapToState(
            clockBloc.state.firstDayOfMonth(),
            activitiesBloc.state.activities,
            clockBloc.state,
          ),
        ) {
    _activitiesSubscription =
        activitiesBloc.listen((state) => add(UpdateMonth()));
    _clockSubscription = clockBloc
        .where((time) =>
            state.weeks
                .expand((w) => w.days)
                .whereType<MonthDay>()
                .firstWhere((day) => day.isCurrent, orElse: () => null)
                ?.day
                ?.isAtSameDay(time) ==
            false)
        .listen((_) => add(UpdateMonth()));
  }

  @override
  Stream<MonthCalendarState> mapEventToState(
    MonthCalendarEvent event,
  ) async* {
    if (event is GoToNextMonth) {
      yield _mapToState(
        state.firstDay.nextMonth(),
        activitiesBloc.state.activities,
        clockBloc.state,
      );
    } else if (event is GoToPreviousMonth) {
      yield _mapToState(
        state.firstDay.previousMonth(),
        activitiesBloc.state.activities,
        clockBloc.state,
      );
    } else if (event is GoToCurrentMonth) {
      yield _mapToState(
        clockBloc.state.firstDayOfMonth(),
        activitiesBloc.state.activities,
        clockBloc.state,
      );
    } else if (event is UpdateMonth) {
      yield _mapToState(
        state.firstDay,
        activitiesBloc.state.activities,
        clockBloc.state,
      );
    }
  }

  static MonthCalendarState _mapToState(
    DateTime firstDayOfMonth,
    Iterable<Activity> activities,
    DateTime now,
  ) {
    assert(firstDayOfMonth.day == 1);
    assert(firstDayOfMonth.hour == 0);
    assert(firstDayOfMonth.minute == 0);
    assert(firstDayOfMonth.second == 0);
    assert(firstDayOfMonth.millisecond == 0);
    assert(firstDayOfMonth.microsecond == 0);

    final firstDayNextMonth = firstDayOfMonth.nextMonth();
    final lastDayOfMonth = firstDayNextMonth.previousDay();
    final month = firstDayOfMonth.month;

    var dayIterator = firstDayOfMonth.firstInWeek();
    final weekData = [
      for (int week = firstDayOfMonth.getWeekNumber();
          !dayIterator.isAfter(lastDayOfMonth);
          week = dayIterator.getWeekNumber())
        MonthWeek(
          week,
          [
            for (int d = 0;
                d < DateTime.daysPerWeek;
                dayIterator = dayIterator.nextDay(), d++)
              if (dayIterator.month == month)
                _getDay(activities, dayIterator, now)
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
        .toList();
    if (activitiesThatDay.isEmpty) {
      return MonthDay(day, null, false, 0, occasion);
    }
    final fullDayActivity = activitiesThatDay
        .firstWhere((a) => a.activity.fullDay, orElse: () => null);
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
    await _activitiesSubscription.cancel();
    await _clockSubscription.cancel();
    return super.close();
  }
}
