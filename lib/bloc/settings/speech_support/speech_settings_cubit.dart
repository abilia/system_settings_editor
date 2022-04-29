import 'package:acapela_tts/acapela_tts.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/tts/tts_handler.dart';

part 'speech_settings_state.dart';

class SpeechSettingsCubit extends Cubit<SpeechSettingsState> {
  final SettingsDb settingsDb;
  final AcapelaTts _acapelaTts = GetIt.I<TtsInterface>() as AcapelaTtsHandler;

  SpeechSettingsCubit({
    required this.settingsDb,
  }) : super(
          SpeechSettingsState(
              speechRate: settingsDb.speechRate,
              speakEveryWord: settingsDb.speakEveryWord,
              voice: settingsDb.voice),
        );

  setSpeechRate(double speechRate) {
    _acapelaTts.setSpeechRate(speechRate);
    emit(state.copyWith(speechRate: speechRate));
  }

  setVoice(String voice) {
    _acapelaTts.setVoice(voice);
    emit(state.copyWith(voice: voice));
  }

  save() async {
    await settingsDb.setSpeechRate(state.speechRate);
    await settingsDb.setVoice(state.voice);
  }

  reset() async {
    emit(SpeechSettingsState(
        speechRate: settingsDb.speechRate,
        speakEveryWord: settingsDb.speakEveryWord,
        voice: settingsDb.voice));
    _acapelaTts.setSpeechRate(state.speechRate);
    _acapelaTts.setVoice(state.voice);
  }
}
