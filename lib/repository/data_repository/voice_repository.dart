import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/utils/strings.dart';

class VoiceRepository {
  VoiceRepository({
    required this.client,
    required this.voicesPath,
  });

  final BaseClient client;
  final String voicesPath;

  static const String _baseUrl = 'https://handi.se/systemfiles2';
  final _log = Logger((VoiceRepository).toString());

  Future<List<VoiceData>> readAvailableVoices(String locale) async {
    var url = '$_baseUrl/$locale/'.toUri();
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
