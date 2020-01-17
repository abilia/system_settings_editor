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
