import 'dart:async';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/repository/data_repository/voice_repository.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required Stream<Locale> localeStream,
  }) : super(const VoicesState()) {
    _localeSubscription = localeStream
        .map((locale) => locale.languageCode)
        .listen(_changeLanguage);
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  late final StreamSubscription _localeSubscription;

  Future<void> fetchVoices(String languageCode) async {
    emit(
      state.copyWith(
        available: await voiceRepository.readAvailableVoices(languageCode),
        downloaded: await voiceRepository.readDownloadedVoices(),
      ),
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    emit(
      state.copyWith(
        available: await voiceRepository.readAvailableVoices(languageCode),
      ),
    );
    speechSettingsCubit.setVoice('');
  }

  Future<void> downloadVoice(VoiceData voice) async {
    emit(
      state.copyWith(
        downloading: [...state.downloading, voice.name],
      ),
    );
    bool downloadSuccess = await voiceRepository.downloadVoice(voice);
    final downloadingVoices = state.downloading..remove(voice.name);

    if (!downloadSuccess) {
      _log.warning('Failed downloading $voice');
      emit(state.copyWith(downloading: downloadingVoices));
    }

    _log.fine('Downloaded voice; $voice');
    if (speechSettingsCubit.state.voice.isEmpty) {
      await speechSettingsCubit.setVoice(voice.name);
    }

    await speechSettingsCubit.setTextToSpeech(true);

    emit(
      state.copyWith(
        downloaded: [...state.downloaded, voice.name],
        downloading: downloadingVoices,
      ),
    );
  }

  Future<void> deleteVoice(VoiceData voice) async {
    await voiceRepository.deleteVoice(voice);
    final downloaded = [...state.downloaded]..remove(voice.name);
    if (speechSettingsCubit.state.voice == voice.name) {
      speechSettingsCubit.setVoice('');
    }
    emit(state.copyWith(downloaded: downloaded));
  }

  Future<void> deleteAllVoices() async {
    while (state.downloading.isNotEmpty) {
      _log.warning(
        "can't delete while downloading, retrying in 2 seconds",
      );
      await Future.delayed(const Duration(seconds: 2));
    }
    await voiceRepository.deleteAllVoices();
    emit(state.copyWith(downloaded: []));
    await speechSettingsCubit.setVoice('');
    await speechSettingsCubit.setTextToSpeech(false);
  }

  @override
  Future<void> close() {
    _localeSubscription.cancel();
    return super.close();
  }
}

class VoicesState extends Equatable {
  final List<VoiceData> available;
  final List<String> downloaded;
  final List<String> downloading;

  const VoicesState({
    this.downloading = const [],
    this.downloaded = const [],
    this.available = const [],
  });

  VoicesState copyWith({
    List<VoiceData>? available,
    List<String>? downloaded,
    List<String>? downloading,
  }) =>
      VoicesState(
        available: available ?? this.available,
        downloaded: downloaded ?? this.downloaded,
        downloading: downloading ?? this.downloading,
      );

  @override
  List<Object?> get props => [
        downloading,
        downloaded,
        available,
      ];
}

class VoicesLoading extends VoicesState {
  const VoicesLoading({required String languageCode}) : super();
}
