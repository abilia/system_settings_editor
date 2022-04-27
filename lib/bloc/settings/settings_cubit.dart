import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/db/all.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsDb settingsDb;

  SettingsCubit({
    required this.settingsDb,
  }) : super(SettingsState(textToSpeech: settingsDb.textToSpeech, speechRate: settingsDb.speechRate, speakEveryWord: settingsDb.speakEveryWord, voice: settingsDb.voice));

  Future<void> setTextToSpeech(bool textToSpeech) async {
    await settingsDb.setTextToSpeech(textToSpeech);
    emit(state.copyWith(textToSpeech: textToSpeech));
  }

  Future<void> setSpeechRate(double speechRate) async {
    await settingsDb.setSpeechRate(speechRate);
    emit(state.copyWith(speechRate: speechRate));
  }

  Future<void> setVoice(String voice) async {
    await settingsDb.setVoice(voice);
    emit(state.copyWith(voice: voice));
  }
}
