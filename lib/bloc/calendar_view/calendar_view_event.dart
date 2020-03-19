import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/calendar_view/calendar_view_state.dart';

abstract class CalendarViewEvent extends Equatable {
  const CalendarViewEvent();
}

class CalendarViewChanged extends CalendarViewEvent {
  final CalendarViewType calendarView;

  const CalendarViewChanged(this.calendarView);

  @override
  List<Object> get props => [calendarView];
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
