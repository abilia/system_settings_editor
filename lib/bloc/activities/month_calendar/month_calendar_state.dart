part of 'month_calendar_bloc.dart';

class MonthCalendarState extends Equatable {
  final DateTime firstDay;
  final List<MonthWeek> weeks;
  final Occasion occasion;
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
  final int day;
  final Activity fullDayActivity;
  final int fullDayActivityCount;
  final bool hasActivities;

  MonthDay(
    this.day,
    this.fullDayActivity,
    this.hasActivities,
    this.fullDayActivityCount,
  );

  @override
  List<Object> get props => [
        day,
        fullDayActivity,
        hasActivities,
        fullDayActivityCount,
      ];
  @override
  bool get stringify => true;
}

class NotInMonthDay extends MonthCalendarDay {
  @override
  List<Object> get props => [];
}
