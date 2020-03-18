import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class CalendarViewBloc extends Bloc<CalendarViewEvent, CalendarViewState> {
  @override
  CalendarViewState get initialState =>
      CalendarViewState(CalendarViewType.LIST);

  @override
  Stream<CalendarViewState> mapEventToState(
    CalendarViewEvent event,
  ) async* {
    if (event is CalendarViewChanged) {
      yield state.copyWith(currentView: event.calendarView);
    }
    if (event is ToggleLeft) {
      yield state.copyWith(expandLeftCategory: !state.expandLeftCategory);
    }
    if (event is ToggleRight) {
      yield state.copyWith(expandRightCategory: !state.expandRightCategory);
    }
  }
}
