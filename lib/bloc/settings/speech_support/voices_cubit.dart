import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required String languageCode,
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required Stream<Locale> localeStream,
  }) : super(VoicesLoading(languageCode: languageCode)) {
    _localeSubscription = localeStream
        .map((locale) => locale.languageCode)
        .listen(readAvailableVoices);
    _initialize(languageCode);
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  late final StreamSubscription _localeSubscription;

  Future<void> _initialize(String languageCode) async {
    final allAvailible =
        await voiceRepository.readAvailableVoices(languageCode);
    final downloaded = await voiceRepository.readDownloadedVoices();
    emit(
      VoicesState(
        languageCode: languageCode,
        allAvailable: {languageCode: allAvailible},
        allDownloaded: {languageCode: downloaded},
      ),
    );
  }

  Future<void> readAvailableVoices([String? languageCode]) async {
    emit(state.copyWith(languageCode: languageCode));
    languageCode ??= state.languageCode;
    final newAvailible =
        await voiceRepository.readAvailableVoices(languageCode);
    if (newAvailible.isEmpty) return;
    emit(
      state.copyWith(
        allAvailable: Map<String, Iterable<VoiceData>>.from(state.allAvailable)
          ..[languageCode] = newAvailible,
      ),
    );
    speechSettingsCubit.setVoice('');
  }

  Future<void> downloadVoice(VoiceData voice) async {
    emit(state.copyWith(downloading: [...state.downloading, voice.name]));
    final downloadSuccess = await voiceRepository.downloadVoice(voice);

    emit(
      state.copyWith(downloading: [...state.downloading]..remove(voice.name)),
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
      state.copyWith(
        allDownloaded: Map<String, Iterable<String>>.from(state.allDownloaded)
          ..[voice.lang] = {
            ...(state.allDownloaded[voice.lang] ?? {}),
            voice.name,
          },
      ),
    );
  }

  Future<void> deleteVoice(VoiceData voice) async {
    await voiceRepository.deleteVoice(voice);
    if (speechSettingsCubit.state.voice == voice.name) {
      speechSettingsCubit.setVoice('');
    }

    final downloadedCopy = Map<String, Set<String>>.from(state.allDownloaded);
    downloadedCopy[state.languageCode] = state.downloaded..remove(voice.name);
    emit(state.copyWith(allDownloaded: downloadedCopy));
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
    await _initialize(state.languageCode);
  }

  @override
  Future<void> close() {
    _localeSubscription.cancel();
    return super.close();
  }
}

class VoicesState extends Equatable {
  final UnmodifiableMapView<String, UnmodifiableSetView<VoiceData>>
      allAvailable;
  final UnmodifiableMapView<String, UnmodifiableSetView<String>> allDownloaded;
  final UnmodifiableListView<String> downloading;
  final String languageCode;

  Set<VoiceData> get available => allAvailable[languageCode]?.toSet() ?? {};
  Set<String> get downloaded => allDownloaded[languageCode]?.toSet() ?? {};

  VoicesState({
    required this.languageCode,
    List<String> downloading = const [],
    Map<String, Iterable<String>> allDownloaded = const {},
    Map<String, Iterable<VoiceData>> allAvailable = const {},
  })  : downloading = UnmodifiableListView(downloading),
        allAvailable =
            UnmodifiableMapView<String, UnmodifiableSetView<VoiceData>>(
          allAvailable.map((key, value) =>
              MapEntry(key, UnmodifiableSetView(value.toSet()))),
        ),
        allDownloaded =
            UnmodifiableMapView<String, UnmodifiableSetView<String>>(
          allDownloaded.map((key, value) =>
              MapEntry(key, UnmodifiableSetView(value.toSet()))),
        );

  VoicesState copyWith({
    String? languageCode,
    Map<String, Iterable<VoiceData>>? allAvailable,
    Map<String, Iterable<String>>? allDownloaded,
    List<String>? downloading,
  }) =>
      VoicesState(
        languageCode: languageCode ?? this.languageCode,
        allAvailable: allAvailable ?? this.allAvailable,
        allDownloaded: allDownloaded ?? this.allDownloaded,
        downloading: downloading ?? this.downloading,
      );

  @override
  List<Object?> get props => [
        languageCode,
        downloading,
        allDownloaded,
        allAvailable,
      ];
}

class VoicesLoading extends VoicesState {
  VoicesLoading({required String languageCode})
      : super(languageCode: languageCode);
}
