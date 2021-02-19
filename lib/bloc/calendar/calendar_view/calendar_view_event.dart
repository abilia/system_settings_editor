part of 'calendar_view_bloc.dart';

abstract class CalendarViewEvent extends Equatable {
  const CalendarViewEvent();
  @override
  bool get stringify => true;
}

class CalendarTypeChanged extends CalendarViewEvent {
  final DayCalendarType calendarType;

  const CalendarTypeChanged(this.calendarType);

  @override
  List<Object> get props => [calendarType];
}

class CalendarPeriodChanged extends CalendarViewEvent {
  final CalendarPeriod calendarPeriod;

  const CalendarPeriodChanged(this.calendarPeriod);

  @override
  List<Object> get props => [calendarPeriod];
}

abstract class ToggleCategory extends CalendarViewEvent {
  const ToggleCategory();
  @override
  List<Object> get props => [];
}

class ToggleRight extends ToggleCategory {
  const ToggleRight();
}

class ToggleLeft extends ToggleCategory {
  const ToggleLeft();
}
