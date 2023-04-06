import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';

part 'speech_settings_state.dart';

class SpeechSettingsCubit extends Cubit<SpeechSettingsState> {
  final VoiceDb voiceDb;
  final TtsInterface acapelaTts;

  SpeechSettingsCubit({
    required this.voiceDb,
    required this.acapelaTts,
  }) : super(SpeechSettingsState.fromDb(voiceDb));

  void reload() => emit(SpeechSettingsState.fromDb(voiceDb));

  Future<void> setTextToSpeech(bool textToSpeech) async {
    emit(state.copyWith(textToSpeech: textToSpeech));
    await voiceDb.setTextToSpeech(textToSpeech);
  }

  Future<void> setSpeechRate(double speechRate) async {
    assert(Config.isMP, 'Cannot set speech rate on mpgo!');
    if (state.voice.isNotEmpty) {
      await acapelaTts.setSpeechRate(speechRate);
      emit(state.copyWith(speechRate: speechRate));
      await voiceDb.setSpeechRate(speechRate);
    }
  }

  Future<void> setVoice(String voice) async {
    assert(Config.isMP, 'Cannot set voice on mpgo!');
    if (voice.isNotEmpty) await acapelaTts.setVoice({'voice': voice});
    emit(state.copyWith(voice: voice));
    await voiceDb.setVoice(voice);
  }

  Future<void> setSpeakEveryWord(bool speakEveryWord) async {
    assert(Config.isMP, 'Cannot speak every word on mpgo!');
    emit(state.copyWith(speakEveryWord: speakEveryWord));
    await voiceDb.setSpeakEveryWord(speakEveryWord);
  }
}
