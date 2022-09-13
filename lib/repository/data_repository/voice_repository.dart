import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/utils/all.dart';

class VoiceRepository {
  VoiceRepository({
    required this.client,
    required this.baseUrlDb,
    required this.ttsHandler,
    required String applicationSupportPath,
  }) : voicesPath = p.join(applicationSupportPath, folder);
  static const folder = 'system';

  final BaseClient client;
  final BaseUrlDb baseUrlDb;
  final String voicesPath;
  final TtsInterface ttsHandler;

  static const String baseUrl = 'library.myabilia.com';
  static const String pathSegments = '/voices/v1/index';
  final _log = Logger((VoiceRepository).toString());

  Future<List<VoiceData>> readAvailableVoices(String lang) async {
    final url = Uri.https(
      baseUrl,
      '$pathSegments/$lang',
      {'environment': baseUrlDb.environment},
    );

    try {
      final response = await client.get(url);
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final json = jsonDecode(response.body) as List;
        return json
            .where((jsonVoice) => jsonVoice['type'] == 1)
            .map((jsonVoice) => VoiceData.fromJson(jsonVoice))
            .toList();
      }
      _log.severe(
        'statusCode: ${response.statusCode} when downloading voices from $url',
        response,
      );
    } catch (e) {
      _log.severe('Error when downloading voices from $url, offline?', e);
    }
    return [];
  }

  Future<List<String>> readDownloadedVoices() async =>
      (await ttsHandler.availableVoices)
          .whereNotNull()
          .map((e) => '$e')
          .toList();

  Future<bool> downloadVoice(VoiceData voice) async {
    try {
      await Future.wait<File>(
        voice.files.map(
          (file) async {
            final response = await client.get(file.downloadUrl.toUri());
            final path = _path(file.localPath);
            _log.finer('Creating file; $path');
            final f = await File(path).create(recursive: true);
            await f.writeAsBytes(response.bodyBytes);
            return f;
          },
        ),
        cleanUp: (f) => f.deleteSync(),
        eagerError: true,
      );
      return true;
    } catch (ex) {
      _log.warning('Download failed: $ex');
      return false;
    }
  }

  Future<bool> deleteVoice(VoiceData voice) async {
    try {
      await Future.wait(
        voice.files.map(
          (file) => File(_path(file.localPath)).delete(recursive: true),
        ),
      );
    } on Exception catch (e) {
      _log.warning('Failed to deleted voice; ${voice.name}', e);
      return false;
    }
    _log.fine('Deleted voice; ${voice.name}');
    return true;
  }

  String _path([String path = '']) => p.join(
        voicesPath,
        path.replaceFirst('/$folder/', ''),
      );

  Future<void> deleteAllVoices() async {
    final voicePath = Directory(_path());
    if (await voicePath.exists()) {
      _log.info('Removing all voices in $voicePath');
      await voicePath.delete(recursive: true);
      return;
    } else {
      _log.info('no downloaded voices present');
    }
  }
}
