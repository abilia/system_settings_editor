import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:memoplanner/utils/all.dart';

class VoiceRepository {
  VoiceRepository({
    required this.client,
    required this.baseUrlDb,
    required this.ttsHandler,
    required Directory applicationSupportDirectory,
    required this.tempDirectory,
  }) : _voicesDirectory = Directory(
          p.join(
            applicationSupportDirectory.path,
            folder,
          ),
        );
  static const folder = 'system';

  final BaseClient client;
  final BaseUrlDb baseUrlDb;
  final Directory _voicesDirectory, tempDirectory;
  final TtsInterface ttsHandler;

  static const String baseUrl = 'library.myabilia.com';
  static const String pathSegments = 'voices/v1/metadata';
  final _log = Logger((VoiceRepository).toString());

  Future<Iterable<VoiceData>> readAvailableVoices() async {
    final url = Uri.https(
      baseUrl,
      pathSegments,
      {'environment': baseUrlDb.environment},
    );
    try {
      final response = await client.get(url);
      final statusCode = response.statusCode;
      if (statusCode != 200) {
        throw StatusCodeException(response);
      }
      final decoded = jsonDecode(response.body) as List;
      return decoded
          .exceptionSafeMap(
            VoiceData.fromJson,
            onException: _log.logAndReturnNull,
          )
          .whereNotNull();
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
      if (!zipFile.existsSync()) {
        _log.fine('$voice cache miss: downloading...');
        final response = await client.get(voice.file.downloadUrl);
        if (response.statusCode != 200) {
          throw StatusCodeException(response);
        }
        _verifyDownload(voice.file, response.bodyBytes);
        _log.fine('writing zipfile...');
        await zipFile.writeAsBytes(response.bodyBytes);
      } else {
        _log.fine('$voice cache hit!');
      }

      _log.fine('extracting voice file $zipFile');
      final voiceDir = await _voiceDirectory(voice).create(recursive: true);
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: voiceDir,
      );
    } catch (ex) {
      _log.warning('Failed to download or extracting voice { $voice }', ex);
      await deleteVoice(voice);
      if (zipFile.existsSync()) await zipFile.delete();
      return false;
    }
    return true;
  }

  void _verifyDownload(VoiceFile voiceFile, Uint8List downloadedBytes) {
    if (downloadedBytes.length != voiceFile.sizeB) {
      throw VoiceFileDownloadException(
        voiceFile,
        'voice file size mismatch: '
        '(downloaded ${downloadedBytes.length} bytes '
        '- expected ${voiceFile.sizeB} bytes)',
      );
    }
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
    try {
      final oldFolder = Directory(p.join(_voicesDirectory.path, 'voices'))
          .listSync()
          .firstWhereOrNull((entity) => entity.path.contains(voice.name));
      if (oldFolder == null) {
        _log.warning('could not find $voice among old voices');
        return false;
      }
      await oldFolder.delete(recursive: true);
      _log.info('successfully deleted legacy voice $voice from $oldFolder');
      return true;
    } on Exception catch (e) {
      _log.warning('Failed to deleted voice by legacy', e);
    }
    return false;
  }

  Directory _voiceDirectory(VoiceData voice) => Directory(
        p.join(
          _voicesDirectory.path,
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
    if (await _voicesDirectory.exists()) {
      _log.info('Removing all voices in $_voicesDirectory');
      await _voicesDirectory.delete(recursive: true);
    } else {
      _log.info('no downloaded voices present');
    }
  }
}
