import 'dart:convert';
import 'dart:io';

import 'package:acapela_tts/acapela_tts.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/utils/strings.dart';

import 'voice_data.dart';

class SpeechSupportCubit extends Cubit<SpeechSupportState> {
  SpeechSupportCubit(this.client, this.acapelaTts, this.locale, selectedVoice)
      : super(SpeechSupportState(
            voices: List.empty(growable: true),
            downloadedVoices: List.empty(growable: true),
            selectedVoice: selectedVoice)) {
    _readAvailableVoices();
    _readDownloadedVoices();
  }

  final BaseClient client;
  final AcapelaTts acapelaTts;
  final String locale;
  static const String _baseUrl = 'https://handi.se/systemfiles2';
  final _log = Logger((SpeechSupportCubit).toString());

  VoiceData getVoice(String name) =>
      state.voices.firstWhere((voice) => voice.name == name);

  void _readAvailableVoices() async {
    var url = '$_baseUrl/$locale'.toUri();
    final response = await client.get(url);

    final statusCode = response.statusCode;
    if (statusCode == 200 && !isClosed) {
      final json = jsonDecode(response.body) as List;
      emit(state.copyWith(
          voices:
              json.map((jsonVoice) => VoiceData.fromJson(jsonVoice)).toList()));
    } else if (statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception(response.body);
    }
  }

  void _readDownloadedVoices() async {
    final List<Object?>? voices = await acapelaTts.availableVoices;
    if (voices != null && !isClosed) {
      emit(state.copyWith(
          downloadedVoices: (voices.map((e) => e.toString())).toList()));
    }
  }

  void selectVoice(VoiceData voice) {
    emit(state.copyWith(selectedVoice: voice.name));
  }

  void downloadVoice(VoiceData voice) async {
    emit(state.copyWith(downloadingVoice: voice.name));
    final dls = voice.files.map((file) async {
      final response = await client.get(file.downloadUrl.toUri());
      final path = await voicesDir + file.localPath;
      _log.finer('creating file; $path');
      final f = await File(path).create(recursive: true);
      await f.writeAsBytes(response.bodyBytes);
    });
    await Future.wait(dls);
    _log.fine('Downloaded voice; ${voice.name}');
    if (!isClosed) {
      emit(state.copyWith(
          selectedVoice: state.downloadedVoices.isEmpty ? voice.name : null,
          downloadingVoice: '',
          downloadedVoices: List.from(state.downloadedVoices)
            ..add(voice.name)));
    }
  }

  void deleteVoice(VoiceData voice) async {
    final dls = voice.files.map((file) async {
      final path = await voicesDir + file.localPath;
      File(path).delete(recursive: true);
    });
    await Future.wait(dls);
    _log.fine('Deleted voice; ${voice.name}');
    if (!isClosed) {
      emit(state.copyWith(
          downloadedVoices: List.from(state.downloadedVoices)
            ..remove(voice.name)));
    }
  }

  Future<String> get voicesDir async =>
      (await getApplicationSupportDirectory()).path;
}

class SpeechSupportState extends Equatable {
  final List<VoiceData> voices;
  final String selectedVoice;
  final String downloadingVoice;
  final List<String> downloadedVoices;

  const SpeechSupportState({
    this.downloadingVoice = '',
    required this.downloadedVoices,
    required this.voices,
    required this.selectedVoice,
  });

  SpeechSupportState copyWith({
    List<VoiceData>? voices,
    List<String>? downloadedVoices,
    String? selectedVoice,
    String? downloadingVoice,
  }) {
    return SpeechSupportState(
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
