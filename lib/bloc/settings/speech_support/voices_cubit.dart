import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/data_repository/voice_repository.dart';
import 'package:seagull/tts/tts_handler.dart';

part '../../../models/settings/speech_support/voice_data.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit({
    required this.voiceRepository,
    required this.ttsHandler,
    required this.locale,
    required String voice,
  }) : super(
          VoicesState(
              voices: List.empty(),
              downloadingVoice: '',
              downloadedVoices: List.empty(),
              selectedVoice: voice),
        ) {
    initialize();
  }

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

  VoiceData getVoice(String name) =>
      state.voices.firstWhere((voice) => voice.name == name);

  Future<List<String>> _readDownloadedVoices() async {
    final List<Object?>? voices = await ttsHandler.availableVoices;
    if (voices != null && !isClosed) {
      return (voices.map((e) => e.toString())).toList();
    }
    return List.empty();
  }

  void selectVoice(VoiceData voice) {
    emit(state.copyWith(selectedVoice: voice.name));
  }

  Future<void> downloadVoice(VoiceData voice) async {
    emit(state.copyWith(downloadingVoice: voice.name));
    bool result = await voiceRepository.downloadVoice(voice);
    if (result) {
      _log.fine('Downloaded voice; ${voice.name}');
    } else {
      _log.warning('Failed downloading file; ${voice.name}');
    }
    if (result) {
      emit(state.copyWith(
          selectedVoice: state.downloadedVoices.isEmpty ? voice.name : null,
          downloadingVoice: '',
          downloadedVoices: List.from(state.downloadedVoices)
            ..add(voice.name)));
    } else {
      emit(state.copyWith(downloadingVoice: ''));
    }
  }

  Future<void> deleteVoice(VoiceData voice) async {
    await voiceRepository.deleteVoice(voice);
    emit(
      state.copyWith(
        downloadedVoices: List.from(state.downloadedVoices)..remove(voice.name),
      ),
    );
  }
}

class VoicesState extends Equatable {
  final List<VoiceData> voices;
  final String selectedVoice;
  final String downloadingVoice;
  final List<String> downloadedVoices;

  const VoicesState({
    required this.downloadingVoice,
    required this.downloadedVoices,
    required this.voices,
    required this.selectedVoice,
  });

  VoicesState copyWith({
    List<VoiceData>? voices,
    List<String>? downloadedVoices,
    String? selectedVoice,
    String? downloadingVoice,
  }) {
    return VoicesState(
        voices: voices ?? this.voices,
        selectedVoice: selectedVoice ?? this.selectedVoice,
        downloadedVoices: downloadedVoices ?? this.downloadedVoices,
        downloadingVoice: downloadingVoice ?? this.downloadingVoice);
  }

  @override
  List<Object?> get props => [
        selectedVoice,
        downloadingVoice,
        downloadedVoices,
        voices,
      ];
}
