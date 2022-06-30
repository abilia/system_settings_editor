import 'package:collection/collection.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/repository/data_repository/voice_repository.dart';
import 'package:seagull/tts/tts_handler.dart';

const _defaultLanguageCode = 'en';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required this.ttsHandler,
  }) : super(const VoicesState()) {
    _initialize();
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  final TtsInterface ttsHandler;

  void _initialize() async {
    final languageCode = await _currentLanguageCode();
    emit(
      VoicesState(
        available: await voiceRepository.readAvailableVoices(languageCode),
        downloaded: await _readDownloadedVoices(),
        languageCode: languageCode,
      ),
    );
  }

  Future<String> _currentLanguageCode() async {
    final languageCode =
        (await Devicelocale.currentLocale)?.split(RegExp('-|_'))[0];
    final languageIsSupported = Locales.language.keys
        .any((locale) => locale.languageCode == languageCode);
    return languageIsSupported
        ? languageCode ?? _defaultLanguageCode
        : _defaultLanguageCode;
  }

  Future<void> updateLocale() async {
    final languageCode = await _currentLanguageCode();

    emit(state.copyWith(
      available: await voiceRepository.readAvailableVoices(languageCode),
      languageCode: languageCode,
    ));
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
      _log.warning('Failed downloading file; ${voice.name}');
      return emit(state.copyWith(downloading: downloadingVoices));
    }

    _log.fine('Downloaded voice; ${voice.name}');
    if (speechSettingsCubit.state.voice.isEmpty) {
      await speechSettingsCubit.setVoice(voice.name);
    }

    return emit(
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
    return emit(state.copyWith(downloaded: downloaded));
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
    this.languageCode = _defaultLanguageCode,
  });

  VoicesState copyWith({
    List<VoiceData>? available,
    List<String>? downloaded,
    List<String>? downloading,
    String? languageCode,
  }) {
    return VoicesState(
      available: available ?? this.available,
      downloaded: downloaded ?? this.downloaded,
      downloading: downloading ?? this.downloading,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        downloading,
        downloaded,
        available,
        languageCode,
      ];
}
