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
      yield CalendarViewState(event.calendarView);
    }
  }
}
