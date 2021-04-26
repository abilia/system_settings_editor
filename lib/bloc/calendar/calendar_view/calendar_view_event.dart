part of 'calendar_view_bloc.dart';

abstract class CalendarViewEvent extends Equatable {
  const CalendarViewEvent();
  @override
  bool get stringify => true;
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
