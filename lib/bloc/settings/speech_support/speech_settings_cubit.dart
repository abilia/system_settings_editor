import 'package:acapela_tts/acapela_tts.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/db/all.dart';

part 'speech_settings_state.dart';

class SpeechSettingsCubit extends Cubit<SpeechSettingsState> {
  final VoiceDb voiceDb;
  final AcapelaTts acapelaTts;

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
    acapelaTts.setSpeechRate(speechRate);
    emit(state.copyWith(speechRate: speechRate));
    await voiceDb.setSpeechRate(state.speechRate);
  }

  Future<void> setVoice(String voice) async {
    acapelaTts.setVoice(voice);
    emit(state.copyWith(voice: voice));
    await voiceDb.setVoice(state.voice);
  }

  void save() async {}

  void reset() async {
    emit(SpeechSettingsState(
        speechRate: voiceDb.speechRate,
        speakEveryWord: voiceDb.speakEveryWord,
        voice: voiceDb.voice));
  }
}
