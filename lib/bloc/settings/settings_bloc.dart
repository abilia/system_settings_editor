import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsDb settingsDb;

  SettingsBloc({
    @required this.settingsDb,
  });

  @override
  SettingsState get initialState =>
      SettingsState(settingsDb.getDotsInTimepillar());

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is DotsInTimepillarUpdated) {
      await settingsDb.setDotsInTimepillar(event.dotsInTimepillar);
      yield SettingsState(event.dotsInTimepillar);
    }
  }
}