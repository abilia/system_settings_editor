import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

part 'calendar_view_event.dart';
part 'calendar_view_state.dart';

class CalendarViewBloc extends Bloc<CalendarViewEvent, CalendarViewState> {
  final SettingsDb settingsDb;
  CalendarViewBloc(this.settingsDb)
      : super(CalendarViewState.fromSettings(settingsDb));

  @override
  Stream<CalendarViewState> mapEventToState(
    CalendarViewEvent event,
  ) async* {
    if (event is CalendarViewChanged) {
      yield state.copyWith(currentView: event.calendarView);
      await settingsDb.setPreferredCalendar(event.calendarView);
    }
    if (event is ToggleLeft) {
      yield state.copyWith(expandLeftCategory: !state.expandLeftCategory);
      await settingsDb.setLeftCategoryExpanded(!state.expandLeftCategory);
    }
    if (event is ToggleRight) {
      yield state.copyWith(expandRightCategory: !state.expandRightCategory);
      await settingsDb.setRightCategoryExpanded(!state.expandRightCategory);
    }
  }
}
