part of 'month_calendar_bloc.dart';

class MonthCalendarState extends Equatable {
  final DateTime firstDay;
  final List<MonthWeek> weeks;
  final Occasion occasion;

  int get index => firstDay.year * DateTime.monthsPerYear + firstDay.month;

  const MonthCalendarState({
    @required this.firstDay,
    @required this.occasion,
    @required this.weeks,
  });

  @override
  List<Object> get props => [firstDay, occasion, weeks];

  @override
  bool get stringify => true;
}

class MonthWeek extends Equatable {
  final int number;
  final List<MonthCalendarDay> days;
  MonthWeek(this.number, this.days);

  @override
  List<Object> get props => [number, days];
  @override
  bool get stringify => true;
}

abstract class MonthCalendarDay extends Equatable {}

class MonthDay extends MonthCalendarDay {
  final DateTime day;
  final ActivityDay fullDayActivity;
  final int fullDayActivityCount;
  final bool hasActivities;
  final Occasion occasion;
  bool get isCurrent => occasion == Occasion.current;
  bool get isPast => occasion == Occasion.past;

  MonthDay(
    this.day,
    this.fullDayActivity,
    this.hasActivities,
    this.fullDayActivityCount,
    this.occasion,
  );

  @override
  List<Object> get props => [
        day,
        fullDayActivity,
        hasActivities,
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