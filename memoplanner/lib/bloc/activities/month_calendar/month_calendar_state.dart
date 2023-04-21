part of 'month_calendar_cubit.dart';

class MonthCalendarState {
  final DateTime firstDay;
  final List<MonthWeek> weeks;
  final Occasion occasion;
  final bool showMonthPreview;

  int get index => firstDay.year * DateTime.monthsPerYear + firstDay.month;

  const MonthCalendarState({
    required this.firstDay,
    required this.occasion,
    required this.weeks,
    required this.showMonthPreview,
  });

  MonthCalendarState copyWith({
    DateTime? firstDay,
    List<MonthWeek>? weeks,
    Occasion? occasion,
    bool? showMonthPreview,
  }) =>
      MonthCalendarState(
        firstDay: firstDay ?? this.firstDay,
        weeks: weeks ?? this.weeks,
        occasion: occasion ?? this.occasion,
        showMonthPreview: showMonthPreview ?? this.showMonthPreview,
      );

  @override
  String toString() => 'MonthCalendarState { '
      'firstDay: $firstDay '
      'occasion: $occasion '
      'showMonthPreview: $showMonthPreview '
      'index: $index '
      '}';
}

class MonthWeek extends Equatable {
  final int number;
  final List<MonthCalendarDay> days;

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
  final bool hasEvent;
  final Occasion occasion;

  bool get isCurrent => occasion.isCurrent;

  bool get isPast => occasion.isPast;

  MonthDay(
    this.day,
    this.fullDayActivity,
    this.hasEvent,
    this.fullDayActivityCount,
    this.occasion,
  );

  @override
  List<Object?> get props => [
        day,
        fullDayActivity,
        hasEvent,
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
