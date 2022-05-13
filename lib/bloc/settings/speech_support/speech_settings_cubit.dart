import 'package:acapela_tts/acapela_tts.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/tts/tts_handler.dart';

part 'speech_settings_state.dart';

class SpeechSettingsCubit extends Cubit<SpeechSettingsState> {
  final SettingsDb settingsDb;
  final AcapelaTts acapelaTts;

  SpeechSettingsCubit({
    required this.settingsDb,
    required this.acapelaTts,
  }) : super(
          SpeechSettingsState(
              speechRate: settingsDb.speechRate,
              speakEveryWord: settingsDb.speakEveryWord,
              voice: settingsDb.voice),
        );

  void setSpeechRate(double speechRate) {
    acapelaTts.setSpeechRate(speechRate);
    emit(state.copyWith(speechRate: speechRate));
  }

  void setVoice(String voice) {
    acapelaTts.setVoice(voice);
    emit(state.copyWith(voice: voice));
  }

  void save() async {
    await settingsDb.setSpeechRate(state.speechRate);
    await settingsDb.setVoice(state.voice);
  }

  void reset() async {
    emit(SpeechSettingsState(
        speechRate: settingsDb.speechRate,
        speakEveryWord: settingsDb.speakEveryWord,
        voice: settingsDb.voice));
    acapelaTts.setSpeechRate(state.speechRate);
    acapelaTts.setVoice(state.voice);
  }
}
