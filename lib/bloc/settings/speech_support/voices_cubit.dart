import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/repository/data_repository/voice_repository.dart';
import 'package:seagull/tts/tts_handler.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required this.speechSettingsCubit,
    required this.voiceRepository,
    required this.ttsHandler,
    required String locale,
  }) : super(VoicesState()) {
    _initialize(locale);
  }

  final _log = Logger((VoicesCubit).toString());
  final VoiceRepository voiceRepository;
  final SpeechSettingsCubit speechSettingsCubit;
  final TtsInterface ttsHandler;

  void _initialize(String locale) async {
    final availableVoices = await voiceRepository.readAvailableVoices(locale);
    final downloadedVoices = await _readDownloadedVoices();
    emit(
      VoicesState(
        availible: availableVoices,
        downloaded: downloadedVoices,
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
    if (speechSettingsCubit.state.voice == voice.name &&
        downloaded.isNotEmpty) {
      speechSettingsCubit.setVoice(downloaded.first);
    }
    emit(state.copyWith(downloaded: downloaded));
  }
}

class VoicesState extends Equatable {
  final List<VoiceData> availible;
  final List<String> downloaded;
  final List<String> downloading;

  late final bool downloadning = downloading.isNotEmpty;

  VoicesState({
    this.downloading = const [],
    this.downloaded = const [],
    this.availible = const [],
  });

  VoicesState copyWith({
    List<VoiceData>? availible,
    List<String>? downloaded,
    List<String>? downloading,
  }) {
    return VoicesState(
      availible: availible ?? this.availible,
      downloaded: downloaded ?? this.downloaded,
      downloading: downloading ?? this.downloading,
    );
  }

  @override
  List<Object?> get props => [
        downloading,
        downloaded,
        availible,
      ];
}
