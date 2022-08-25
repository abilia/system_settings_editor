import 'dart:async';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/voice_db.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/repository/data_repository/voice_repository.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required String languageCode,
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required Stream<Locale> localeStream,
  }) : super(const VoicesLoading()) {
    _localeSubscription = localeStream
        .map((locale) => locale.languageCode)
        .listen(readAvailableVoices);
    _initialize(languageCode);
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  late final StreamSubscription _localeSubscription;

  Future<void> _initialize(String languageCode) async => emit(
        state.copyWith(
          allAvailable:
              (await voiceRepository.readAvailableVoices(languageCode)).toSet(),
          downloaded: await voiceRepository.readDownloadedVoices(),
        ),
      );

  Future<void> readAvailableVoices(String languageCode) async {
    final allAvailable = Set<VoiceData>.from(state.allAvailable)
      ..addAll(await voiceRepository.readAvailableVoices(languageCode));
    emit(
      state.copyWith(allAvailable: allAvailable),
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
    final downloadingVoices = [...state.downloading]..remove(voice.name);

    if (!downloadSuccess) {
      _log.warning('Failed downloading $voice');
      emit(state.copyWith(downloading: downloadingVoices));
      return;
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

  Future<void> resetSpeechSettings() async {
    await speechSettingsCubit.setSpeechRate(VoiceDb.defaultSpeechRate);
    await speechSettingsCubit.setSpeakEveryWord(false);
    await speechSettingsCubit.setTextToSpeech(false);
    await speechSettingsCubit.setVoice('');
    await _deleteAllVoices();
  }

  Future<void> _deleteAllVoices() async {
    while (state.downloading.isNotEmpty) {
      _log.warning(
        "can't delete while downloading, retrying in 2 seconds",
      );
      await Future.delayed(const Duration(seconds: 2));
    }
    await voiceRepository.deleteAllVoices();
    emit(state.copyWith(downloaded: []));
  }

  @override
  Future<void> close() {
    _localeSubscription.cancel();
    return super.close();
  }
}

class VoicesState extends Equatable {
  final Set<VoiceData> allAvailable;
  final List<String> downloaded;
  final List<String> downloading;

  List<VoiceData> availableIn(String languageCode) =>
      allAvailable.where((v) => v.lang == languageCode).toList();

  const VoicesState({
    this.downloading = const [],
    this.downloaded = const [],
    this.allAvailable = const {},
  });

  VoicesState copyWith({
    Set<VoiceData>? allAvailable,
    List<String>? downloaded,
    List<String>? downloading,
  }) =>
      VoicesState(
        allAvailable: allAvailable ?? this.allAvailable,
        downloaded: downloaded ?? this.downloaded,
        downloading: downloading ?? this.downloading,
      );

  @override
  List<Object?> get props => [
        downloading,
        downloaded,
        allAvailable,
      ];
}

class VoicesLoading extends VoicesState {
  const VoicesLoading() : super();
}
