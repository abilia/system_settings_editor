part of 'month_calendar_bloc.dart';

abstract class MonthCalendarEvent extends Equatable {
  const MonthCalendarEvent();

  @override
  List<Object> get props => [];
}

class GoToNextMonth extends MonthCalendarEvent {}

class GoToPreviousMonth extends MonthCalendarEvent {}

class GoToCurrentMonth extends MonthCalendarEvent {}

class UpdateMonth extends MonthCalendarEvent {}
