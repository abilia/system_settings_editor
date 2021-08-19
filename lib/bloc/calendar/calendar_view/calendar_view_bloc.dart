import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

part 'calendar_view_event.dart';
part 'calendar_view_state.dart';

class CalendarViewBloc extends Bloc<ToggleCategory, CalendarViewState> {
  final SettingsDb settingsDb;
  CalendarViewBloc(this.settingsDb)
      : super(CalendarViewState.fromSettings(settingsDb));

  @override
  Stream<CalendarViewState> mapEventToState(
    ToggleCategory event,
  ) async* {
    if (event.category == Category.right) {
      yield state.copyWith(expandRightCategory: !state.expandRightCategory);
      await settingsDb.setRightCategoryExpanded(!state.expandRightCategory);
    } else {
      yield state.copyWith(expandLeftCategory: !state.expandLeftCategory);
      await settingsDb.setLeftCategoryExpanded(!state.expandLeftCategory);
    }
  }
}
