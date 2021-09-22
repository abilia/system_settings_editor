import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

part 'calendar_view_event.dart';
part 'calendar_view_state.dart';

class CalendarViewCubit extends Cubit<CalendarViewState> {
  final SettingsDb settingsDb;
  CalendarViewCubit(this.settingsDb)
      : super(CalendarViewState.fromSettings(settingsDb));

  Future toggle(int category) async {
    if (category == Category.right) {
      emit(state.copyWith(expandRightCategory: !state.expandRightCategory));
      await settingsDb.setRightCategoryExpanded(state.expandRightCategory);
    } else {
      emit(state.copyWith(expandLeftCategory: !state.expandLeftCategory));
      await settingsDb.setLeftCategoryExpanded(state.expandLeftCategory);
    }
  }
}
