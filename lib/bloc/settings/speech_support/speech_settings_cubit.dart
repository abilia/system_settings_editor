import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/config.dart';
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
            textToSpeech: voiceDb.textToSpeech,
            speechRate: voiceDb.speechRate,
            speakEveryWord: voiceDb.speakEveryWord,
            voice: voiceDb.voice,
          ),
        );

  Future<void> setTextToSpeech(bool textToSpeech) async {
    await voiceDb.setTextToSpeech(textToSpeech);
    emit(state.copyWith(textToSpeech: textToSpeech));
  }

  Future<void> setSpeechRate(double speechRate) async {
    assert(Config.isMP, 'Cannot set speech rate on mpgo!');
    if (!Config.isMP) return;
    if (state.voice.isNotEmpty) {
      await acapelaTts.setSpeechRate(speechRate);
      emit(state.copyWith(speechRate: speechRate));
      await voiceDb.setSpeechRate(state.speechRate);
    }
  }

  Future<void> setVoice(String voice) async {
    assert(Config.isMP, 'Cannot set voice on mpgo!');
    if (!Config.isMP) return;
    if (voice.isNotEmpty) await acapelaTts.setVoice({'voice': voice});
    emit(state.copyWith(voice: voice));
    await voiceDb.setVoice(state.voice);
  }

  Future<void> setSpeakEveryWord(bool speakEveryWord) async {
    assert(Config.isMP, 'Cannot speak every word on mpgo!');
    if (!Config.isMP) return;
    emit(state.copyWith(speakEveryWord: speakEveryWord));
    await voiceDb.setSpeakEveryWord(speakEveryWord);
  }
}
