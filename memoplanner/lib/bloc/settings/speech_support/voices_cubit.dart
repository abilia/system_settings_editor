import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

part 'voices_state.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required String languageCode,
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required Stream<Locale> localeStream,
  }) : super(VoicesLoading(languageCode: languageCode)) {
    _localeSubscription = localeStream
        .map((locale) => locale.languageCode)
        .listen(onLocaleChanged);
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  late final StreamSubscription _localeSubscription;

  Future<void> initialize() async {
    emit(
      VoicesState(
        languageCode: state.languageCode,
        allAvailable: await voiceRepository.readAvailableVoices(),
        allDownloaded: await voiceRepository.readDownloadedVoices(),
      ),
    );
  }

  Future<void> onLocaleChanged(String languageCode) async {
    if (state.languageCode == languageCode) return;
    emit(state.copyWith(languageCode: languageCode));
    await _setNewOrUnsetVoice();
  }

  Future<void> readAvailableVoices() async {
    if (state is VoicesLoading) return;
    final newAvailible = await voiceRepository.readAvailableVoices();
    if (newAvailible.isEmpty) return;
    emit(state.copyWith(allAvailable: newAvailible));
  }

  Future<void> downloadVoice(VoiceData voice) async {
    emit(state.copyWith(downloading: {...state.downloading, voice.name}));
    final downloadSuccess = await voiceRepository.downloadVoice(voice);

    emit(
      state.copyWith(downloading: {...state.downloading}..remove(voice.name)),
    );

    if (!downloadSuccess) {
      _log.warning('Failed downloading $voice');
      return;
    }

    _log.fine('Downloaded voice; $voice');
    if (speechSettingsCubit.state.voice.isEmpty) {
      await speechSettingsCubit.setVoice(voice.name);
    }

    await speechSettingsCubit.setTextToSpeech(true);

    emit(
      state.copyWith(allDownloaded: {...state.allDownloaded, voice.name}),
    );
  }

  Future<void> deleteVoice(VoiceData voice) async {
    emit(
      state.copyWith(
        allDownloaded: state.allDownloaded.toSet()..remove(voice.name),
      ),
    );
    if (speechSettingsCubit.state.voice == voice.name) {
      await _setNewOrUnsetVoice();
    }
    await voiceRepository.deleteVoice(voice);
  }

  Future<void> _setNewOrUnsetVoice() async {
    if (state.downloaded.isEmpty) {
      await speechSettingsCubit.setVoice('');
      await speechSettingsCubit.setTextToSpeech(false);
      return;
    }
    await speechSettingsCubit.setVoice(state.downloaded.first);
  }

  Future<void> resetSpeechSettings() async {
    await speechSettingsCubit.setSpeechRate(VoiceDb.defaultSpeechRate);
    await speechSettingsCubit.setSpeakEveryWord(false);
    await speechSettingsCubit.setTextToSpeech(false);
    await speechSettingsCubit.setVoice('');
    emit(VoicesLoading(languageCode: state.languageCode));
    await _deleteAllVoices();
    await initialize();
  }

  Future<void> _deleteAllVoices() async {
    while (state.downloading.isNotEmpty) {
      _log.warning(
        "can't delete while downloading, retrying in 2 seconds",
      );
      await Future.delayed(const Duration(seconds: 2));
    }
    await voiceRepository.deleteAllVoices();
  }

  @override
  Future<void> close() {
    _localeSubscription.cancel();
    return super.close();
  }
}
