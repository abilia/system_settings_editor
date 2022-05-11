import 'package:acapela_tts/acapela_tts.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/config.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/tts/tts_handler.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsDb settingsDb;
  final AcapelaTts? _acapelaTts =
      Config.isMP ? GetIt.I<TtsInterface>() as AcapelaTtsHandler : null;

  SettingsCubit({
    required this.settingsDb,
  }) : super(SettingsState(
            textToSpeech: settingsDb.textToSpeech,
            speechRate: settingsDb.speechRate,
            speakEveryWord: settingsDb.speakEveryWord,
            voice: settingsDb.voice));

  void setTextToSpeech(bool textToSpeech) {
    emit(state.copyWith(textToSpeech: textToSpeech));
  }

  void setSpeechRate(double speechRate) {
    _acapelaTts?.setSpeechRate(speechRate);
    emit(state.copyWith(speechRate: speechRate));
  }

  void setVoice(String voice) {
    _acapelaTts?.setVoice(voice);
    emit(state.copyWith(voice: voice));
  }

  void save() async {
    await settingsDb.setSpeechRate(state.speechRate);
    await settingsDb.setVoice(state.voice);
    await settingsDb.setTextToSpeech(state.textToSpeech);
  }

  void reset() {
    emit(state.copyWith(
        textToSpeech: settingsDb.textToSpeech,
        speechRate: settingsDb.speechRate,
        speakEveryWord: settingsDb.speakEveryWord,
        voice: settingsDb.voice));

    _acapelaTts?.setSpeechRate(settingsDb.speechRate);
    _acapelaTts?.setVoice(settingsDb.voice);
  }
}
