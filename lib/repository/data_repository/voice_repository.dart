import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/bloc/settings/speech_support/voices_cubit.dart';
import 'package:seagull/db/baseurl_db.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/utils/strings.dart';

class VoiceRepository {
  VoiceRepository({
    required this.client,
    required this.baseUrlDb,
  });

  final BaseClient client;
  final BaseUrlDb baseUrlDb;

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
    } else if (statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception(response.body);
    }
  }

  Future<bool> downloadVoice(VoiceData voice) async {
    try {
      final dls = voice.files.map((file) async {
        final response = await client.get(file.downloadUrl.toUri());
        final path = await _voicesDir + file.localPath;
        _log.finer('Creating file; $path');
        final f = await File(path).create(recursive: true);
        await f.writeAsBytes(response.bodyBytes);
      });
      await Future.wait(dls);
      return true;
    } catch (ex) {
      _log.warning('Download failed: ${ex.toString()}');
      return false;
    }
  }

  Future<void> deleteVoice(VoiceData voice) async {
    final dls = voice.files.map((file) async {
      final path = await _voicesDir + file.localPath;
      File(path).delete(recursive: true);
    });
    await Future.wait(dls);
    _log.fine('Deleted voice; ${voice.name}');
  }

  Future<String> get _voicesDir async =>
      (await getApplicationSupportDirectory()).path;
}
