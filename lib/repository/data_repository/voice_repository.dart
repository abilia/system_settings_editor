import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_archive/flutter_archive.dart';
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
    required Directory applicationSupportDirectory,
    required this.tempDirectory,
  }) : voicesDirectory = Directory(
          p.join(
            applicationSupportDirectory.path,
            folder,
          ),
        );
  static const folder = 'system';

  final BaseClient client;
  final BaseUrlDb baseUrlDb;
  final Directory voicesDirectory, tempDirectory;
  final TtsInterface ttsHandler;

  static const String baseUrl = 'library.myabilia.com';
  static const String pathSegments = 'voices/v1/metadata';
  final _log = Logger((VoiceRepository).toString());

  Future<Iterable<VoiceData>> readAvailableVoices({
    bool useEnviromentParameters = true,
  }) async {
    final url = Uri.https(
      baseUrl,
      pathSegments,
      {
        if (useEnviromentParameters) 'environment': baseUrlDb.environment,
      },
    );
    try {
      final response = await client.get(url);
      final statusCode = response.statusCode;
      if (statusCode == 200) {
        final decoded = jsonDecode(response.body) as List;
        if (decoded.isEmpty && useEnviromentParameters) {
          return readAvailableVoices(useEnviromentParameters: false);
        }
        return decoded
            .exceptionSafeMap(
              VoiceData.fromJson,
              onException: _log.logAndReturnNull,
            )
            .whereNotNull();
      }
      _log.severe(
        'statusCode: ${response.statusCode} when fetching voices from $url',
        response,
      );
    } catch (e) {
      _log.severe('Error when fetching voices from $url, offline?', e);
    }
    return [];
  }

  Future<Iterable<String>> readDownloadedVoices() async =>
      (await ttsHandler.availableVoices).whereNotNull().map((e) => '$e');

  Future<bool> downloadVoice(VoiceData voice) async {
    final zipFile = _tempFile(voice);
    try {
      if (!await zipFile.exists()) {
        _log.finer('voice file: $voice does not exist, downloading...');
        final response = await client.get(voice.file.downloadUrl);
        if (response.statusCode != 200) return false;
        await zipFile.writeAsBytes(response.bodyBytes);
      }

      final voiceDir = await _voiceDirectory(voice).create(recursive: true);
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: voiceDir,
      );
    } catch (ex) {
      _log.warning('Failed to download or extracting voice { $voice }', ex);
      await zipFile.delete();
      await deleteVoice(voice);
      return false;
    }
    return true;
  }

  Future<bool> deleteVoice(VoiceData voice) async {
    try {
      await _voiceDirectory(voice).delete(recursive: true);
    } on Exception catch (e) {
      _log.warning('Failed to deleted voice: ${voice.name}', e);
      _log.info('Will try legacy delete');
      return _legacyDelete(voice);
    }
    _log.fine('Deleted voice; ${voice.name}');
    return true;
  }

  /// Memoplanner 4.0 used https://www.handi.se/systemfiles2/{lang}/
  /// and stored files according to the json "localPath"
  Future<bool> _legacyDelete(VoiceData voice) async {
    final oldFolder = Directory(p.join(voicesDirectory.path, 'voices'))
        .listSync()
        .firstWhereOrNull((entity) => entity.path.contains(voice.name));
    try {
      if (oldFolder != null) {
        await oldFolder.delete(recursive: true);
        _log.info('successfully deleted legacy voice $voice from $oldFolder');
        return true;
      }
    } on Exception catch (e) {
      _log.warning('Failed to deleted voice by legacy: $oldFolder', e);
    }
    return false;
  }

  Directory _voiceDirectory(VoiceData voice) => Directory(
        p.join(
          voicesDirectory.path,
          voice.lang,
          voice.countryCode,
          voice.name,
        ),
      );

  File _tempFile(VoiceData voice) => File(
        p.join(
          tempDirectory.path,
          '${voice.file.md5}.zip',
        ),
      );

  Future<void> deleteAllVoices() async {
    if (await voicesDirectory.exists()) {
      _log.info('Removing all voices in $voicesDirectory');
      await voicesDirectory.delete(recursive: true);
    } else {
      _log.info('no downloaded voices present');
    }
  }
}
