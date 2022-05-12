import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/db/all.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsDb settingsDb;

  SettingsCubit({
    required this.settingsDb,
  }) : super(SettingsState(textToSpeech: settingsDb.textToSpeech));

  void setTextToSpeech(bool textToSpeech) {
    emit(state.copyWith(textToSpeech: textToSpeech));
  }

  void reset() {
    emit(state.copyWith(textToSpeech: settingsDb.textToSpeech));
  }

  Future<void> save() async {
    await settingsDb.setTextToSpeech(state.textToSpeech);
  }
}
