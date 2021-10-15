import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/db/all.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsDb settingsDb;

  SettingsBloc({
    required this.settingsDb,
  }) : super(SettingsState(
            textToSpeech: settingsDb.textToSpeech,
            alarmsDisabled: settingsDb.alarmsDisabled));

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is TextToSpeechUpdated) {
      await settingsDb.setTextToSpeech(event.textToSpeech);
      yield state.copyWith(textToSpeech: event.textToSpeech);
    }
    if (event is AlarmsDisabledUpdated) {
      await settingsDb.setAlarmsDisabled(event.alarmsDisabled);
      yield state.copyWith(alarmsDisabled: event.alarmsDisabled);
    }
  }
}
