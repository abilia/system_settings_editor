import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/tts/tts_handler.dart';

part 'speech_settings_state.dart';

class SpeechSettingsCubit extends Cubit<SpeechSettingsState> {
  final VoiceDb voiceDb;
  final TtsInterface acapelaTts;

  SpeechSettingsCubit({
    required this.voiceDb,
    required this.acapelaTts,
  }) : super(
          SpeechSettingsState(
              speechRate: voiceDb.speechRate,
              speakEveryWord: voiceDb.speakEveryWord,
              voice: voiceDb.voice),
        );

  Future<void> setSpeechRate(double speechRate) async {
    if (state.voice.isNotEmpty) {
      await acapelaTts.setSpeechRate(speechRate);
      emit(state.copyWith(speechRate: speechRate));
      await voiceDb.setSpeechRate(state.speechRate);
    }
    return;
  }

  Future<void> setVoice(String voice) async {
    if (voice.isNotEmpty) await acapelaTts.setVoice({'voice': voice});
    emit(state.copyWith(voice: voice));
    return await voiceDb.setVoice(state.voice);
  }

  Future<void> setSpeakEveryWord(bool speakEveryWord) async {
    emit(state.copyWith(speakEveryWord: speakEveryWord));
    return await voiceDb.setSpeakEveryWord(speakEveryWord);
  }
}
