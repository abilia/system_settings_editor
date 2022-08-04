import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/utils/strings.dart';

class VoiceRepository {
  VoiceRepository({
    required this.client,
    required this.voicesPath,
    required this.ttsHandler,
  });

  final BaseClient client;
  final String voicesPath;
  final TtsInterface ttsHandler;

  static const String baseUrl = 'https://handi.se/systemfiles2';
  final _log = Logger((VoiceRepository).toString());

  Future<List<VoiceData>> readAvailableVoices(String locale) async {
    var url = '$baseUrl/$locale/'.toUri();
    final response = await client.get(url);

    final statusCode = response.statusCode;
    if (statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      return json
          .where((jsonVoice) => jsonVoice['type'] == 1)
          .map((jsonVoice) => VoiceData.fromJson(jsonVoice))
          .toList();
    }
    throw Exception(response.body);
  }

  Future<List<String>> readDownloadedVoices() async =>
      (await ttsHandler.availableVoices)
          .whereNotNull()
          .map((e) => '$e')
          .toList();

  Future<bool> downloadVoice(VoiceData voice) async {
    try {
      final dls = voice.files.map((file) async {
        final response = await client.get(file.downloadUrl.toUri());
        final path = voicesPath + file.localPath;
        _log.finer('Creating file; $path');
        final f = await File(path).create(recursive: true);
        await f.writeAsBytes(response.bodyBytes);
      });
      await Future.wait(dls);
      return true;
    } catch (ex) {
      _log.warning('Download failed: $ex');
      return false;
    }
  }

  Future<void> deleteVoice(VoiceData voice) async {
    final dls = voice.files.map(
        (file) => File('$voicesPath${file.localPath}').delete(recursive: true));
    await Future.wait(dls);
    _log.fine('Deleted voice; ${voice.name}');
  }

  Future<void> deleteAllVoices() async {
    final voicePath = Directory('$voicesPath/system/voices');
    if (await voicePath.exists()) {
      _log.info('Removing all voices in $voicePath');
      await voicePath.delete(recursive: true);
      return;
    } else {
      _log.info('no downloaded voices present');
    }
  }
}
