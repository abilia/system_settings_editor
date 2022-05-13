import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/utils/strings.dart';

part 'voice_data.dart';

class VoicesCubit extends Cubit<VoicesState> {
  VoicesCubit(this.client, this.locale, selectedVoice)
      : super(VoicesState(
            voices: List.empty(),
            downloadedVoices: List.empty(),
            selectedVoice: selectedVoice)) {
    initialize();
  }

  void initialize() async {
    final availableVoices = await _readAvailableVoices();
    final downloadedVoices = await _readDownloadedVoices();
    emit(
      state.copyWith(
          voices: availableVoices, downloadedVoices: downloadedVoices),
    );
  }

  final BaseClient client;
  final String locale;
  static const String _baseUrl = 'https://handi.se/systemfiles2';
  final _log = Logger((VoicesCubit).toString());

  VoiceData getVoice(String name) =>
      state.voices.firstWhere((voice) => voice.name == name);

  Future<List<VoiceData>> _readAvailableVoices() async {
    var url = '$_baseUrl/$locale/'.toUri();
    final response = await client.get(url);

    final statusCode = response.statusCode;
    if (statusCode == 200 && !isClosed) {
      final json = jsonDecode(response.body) as List;
      return json
          .where((jsonVoice) => jsonVoice['type'] == 1)
          .map((jsonVoice) => VoiceData.fromJson(jsonVoice))
          .toList();
    } else if (statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<String>> _readDownloadedVoices() async {
    final List<Object?>? voices =
        await (GetIt.I<TtsInterface>() as AcapelaTtsHandler).availableVoices;
    if (voices != null && !isClosed) {
      return (voices.map((e) => e.toString())).toList();
    }
    return List.empty();
  }

  void selectVoice(VoiceData voice) {
    emit(state.copyWith(selectedVoice: voice.name));
  }

  void downloadVoice(VoiceData voice) async {
    emit(state.copyWith(downloadingVoice: voice.name));
    final dls = voice.files.map((file) async {
      final response = await client.get(file.downloadUrl.toUri());
      final path = await voicesDir + file.localPath;
      _log.finer('Creating file; $path');
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

class VoicesState extends Equatable {
  final List<VoiceData> voices;
  final String selectedVoice;
  final String downloadingVoice;
  final List<String> downloadedVoices;

  const VoicesState({
    this.downloadingVoice = '',
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
