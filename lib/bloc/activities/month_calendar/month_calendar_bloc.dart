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
    _activitiesSubscription = activitiesBloc.listen(
      (state) => add(
        UpdateMonthActivites(state.activities),
      ),
    );
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
    } else if (event is ActivitiesLoaded) {
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

    final weekNumber = firstDayOfMonth.getWeekNumber();
    final lastWeekInMonth = lastDayOfMonth.getWeekNumber();

    final mondayOfFirstDayOfMonth = firstDayOfMonth.firstInWeek();

    final month = firstDayOfMonth.month;
    var dayIterator = mondayOfFirstDayOfMonth;
    final weekData = [
      for (int week = weekNumber; week <= lastWeekInMonth; week++)
        MonthWeek(
          week,
          [
            for (int d = 0;
                d < DateTime.daysPerWeek;
                dayIterator = dayIterator.nextDay(), d++)
              if (dayIterator.month == month)
                MonthDay(dayIterator.day, null, false, 0)
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

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    return super.close();
  }
}
