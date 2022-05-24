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
    required this.locale,
    required String voice,
  }) : super(
          VoicesState(
            voices: List.empty(),
            downloadingVoices: List.empty(),
            downloadedVoices: List.empty(),
          ),
        ) {
    initialize();
  }

  final SpeechSettingsCubit speechSettingsCubit;
  final VoiceRepository voiceRepository;
  final TtsInterface ttsHandler;

  void initialize() async {
    final availableVoices = await voiceRepository.readAvailableVoices(locale);
    final downloadedVoices = await _readDownloadedVoices();
    emit(
      state.copyWith(
          voices: availableVoices, downloadedVoices: downloadedVoices),
    );
  }

  final String locale;
  final _log = Logger((VoicesCubit).toString());

  Future<List<String>> _readDownloadedVoices() async =>
      (await ttsHandler.availableVoices)
          .whereNotNull()
          .map((e) => '$e')
          .toList();

  Future<void> downloadVoice(VoiceData voice) async {
    emit(
      state.copyWith(
          downloadingVoices: List.from(state.downloadingVoices)
            ..add(voice.name),
          downloadedVoices: state.downloadedVoices,
          voices: state.voices),
    );
    bool result = await voiceRepository.downloadVoice(voice);
    if (result) {
      _log.fine('Downloaded voice; ${voice.name}');
    } else {
      _log.warning('Failed downloading file; ${voice.name}');
    }
    final downloadingVoices = List<String>.from(state.downloadingVoices)
      ..remove(voice.name);
    if (result) {
      emit(
        state.copyWith(
            downloadingVoices: downloadingVoices,
            downloadedVoices: List.from(state.downloadedVoices)
              ..add(voice.name),
            voices: state.voices),
      );
      if (speechSettingsCubit.state.voice.isEmpty) {
        await speechSettingsCubit.setVoice(voice.name);
      }
    } else {
      emit(state.copyWith(downloadingVoices: downloadingVoices));
    }
  }

  Future<void> deleteVoice(VoiceData voice) async {
    await voiceRepository.deleteVoice(voice);
    final downloadedVoices = List<String>.from(state.downloadedVoices)
      ..remove(voice.name);
    if (speechSettingsCubit.state.voice == voice.name) {
      await speechSettingsCubit.setVoice(downloadedVoices.first);
    }
    state.copyWith(
        downloadingVoices: state.downloadingVoices,
        downloadedVoices: downloadedVoices,
        voices: state.voices);
  }
}

class VoicesState extends Equatable {
  final List<VoiceData> voices;
  final List<String> downloadingVoices;
  final List<String> downloadedVoices;

  const VoicesState({
    required this.downloadingVoices,
    required this.downloadedVoices,
    required this.voices,
  });

  VoicesState copyWith({
    List<VoiceData>? voices,
    List<String>? downloadedVoices,
    List<String>? downloadingVoices,
  }) {
    return VoicesState(
        voices: voices ?? this.voices,
        downloadedVoices: downloadedVoices ?? this.downloadedVoices,
        downloadingVoices: downloadingVoices ?? this.downloadingVoices);
  }

  @override
  List<Object?> get props => [
        downloadingVoices,
        downloadedVoices,
        voices,
      ];
}
