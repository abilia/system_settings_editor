import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/repository/data_repository/voice_repository.dart';
import 'package:seagull/tts/tts_handler.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required String languageCode,
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required this.ttsHandler,
  }) : super(VoicesState(languageCode: languageCode)) {
    _initialize();
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  final TtsInterface ttsHandler;

  void _initialize() async {
    emit(
      state.copyWith(
        available:
            await voiceRepository.readAvailableVoices(state.languageCode),
        downloaded: await _readDownloadedVoices(),
      ),
    );
  }

  Future<void> updateLocale(String languageCode) async {
    final supportedLocals = Locales.language.keys;
    final supportedLocal = supportedLocals.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => supportedLocals.first,
    );

    emit(
      state.copyWith(
        available: await voiceRepository
            .readAvailableVoices(supportedLocal.languageCode),
        languageCode: languageCode,
      ),
    );
  }

  Future<List<String>> _readDownloadedVoices() async =>
      (await ttsHandler.availableVoices)
          .whereNotNull()
          .map((e) => '$e')
          .toList();

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
      speechSettingsCubit.setVoice(
        downloaded.isNotEmpty ? downloaded.first : '',
      );
    }
    emit(state.copyWith(downloaded: downloaded));
  }

  Future<void> deleteAllVoices() async {
    while (state.downloading.isNotEmpty) {
      _log.warning(
        "can't delete while downloadning, retrying in 2 seconds",
      );
      await Future.delayed(const Duration(seconds: 2));
    }
    await voiceRepository.deleteAllVoices();
    emit(state.copyWith(downloaded: []));
    await speechSettingsCubit.setVoice('');
    await speechSettingsCubit.setTextToSpeech(false);
  }
}

class VoicesState extends Equatable {
  final List<VoiceData> available;
  final List<String> downloaded;
  final List<String> downloading;
  final String languageCode;

  const VoicesState({
    this.downloading = const [],
    this.downloaded = const [],
    this.available = const [],
    required this.languageCode,
  });

  VoicesState copyWith({
    List<VoiceData>? available,
    List<String>? downloaded,
    List<String>? downloading,
    String? languageCode,
  }) =>
      VoicesState(
        available: available ?? this.available,
        downloaded: downloaded ?? this.downloaded,
        downloading: downloading ?? this.downloading,
        languageCode: languageCode ?? this.languageCode,
      );

  @override
  List<Object?> get props => [
        downloading,
        downloaded,
        available,
        languageCode,
      ];
}
