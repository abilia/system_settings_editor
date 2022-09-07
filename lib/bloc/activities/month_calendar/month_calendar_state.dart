part of 'month_calendar_cubit.dart';

class MonthCalendarState {
  final DateTime firstDay;
  final List<MonthWeek> weeks;
  final Occasion occasion;

  int get index => firstDay.year * DateTime.monthsPerYear + firstDay.month;

  const MonthCalendarState({
    required this.firstDay,
    required this.occasion,
    required this.weeks,
  });
}

class MonthWeek extends Equatable {
  final int number;
  final List<MonthCalendarDay> days;
  bool get inMonth => days.any((d) => d is MonthDay);
  const MonthWeek(this.number, this.days);

  @override
  List<Object> get props => [number, days];
  @override
  bool get stringify => true;
}

abstract class MonthCalendarDay extends Equatable {}

class MonthDay extends MonthCalendarDay {
  final DateTime day;
  final ActivityDay? fullDayActivity;
  final int fullDayActivityCount;
  final bool hasActivities, hasTimers;
  final Occasion occasion;

  bool get isCurrent => occasion.isCurrent;

  bool get isPast => occasion.isPast;

  bool get hasActivitiesOrTimers => hasActivities || hasTimers;

  MonthDay(
    this.day,
    this.fullDayActivity,
    this.hasActivities,
    this.hasTimers,
    this.fullDayActivityCount,
    this.occasion,
  );

  @override
  List<Object?> get props => [
        day,
        fullDayActivity,
        hasActivities,
        hasTimers,
        fullDayActivityCount,
        occasion,
      ];
  @override
  bool get stringify => true;
}

class NotInMonthDay extends MonthCalendarDay {
  @override
  List<Object> get props => [];
}
