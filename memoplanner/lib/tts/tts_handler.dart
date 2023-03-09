import 'dart:io';

import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/voice_db.dart';
import 'package:memoplanner/logging/all.dart';

abstract class TtsInterface {
  static Future<TtsInterface> implementation({
    required VoiceDb voiceDb,
    required String voicesPath,
  }) async {
    try {
      if (Config.isMP) {
        return await AcapelaTtsHandler.implementation(
          voiceDb: voiceDb,
          voicesPath: voicesPath,
        );
      }
    } catch (e) {
      AcapelaTtsHandler._log.severe('failed to initialize acapela', e);
    }
    return FlutterTtsHandler.implementation();
  }

  Future<dynamic> speak(String text);

  Future<dynamic> stop();

  Future<dynamic> pause();

  Future<dynamic> setVoice(Map<String, String> voice);

  Future<dynamic> setSpeechRate(double speechRate);

  Future<List<Object?>> get availableVoices;
}

class AcapelaTtsHandler extends AcapelaTts implements TtsInterface {
  static final Logger _log = Logger((AcapelaTts).toString());

  static Future<AcapelaTtsHandler> implementation({
    required VoiceDb voiceDb,
    required String voicesPath,
  }) async {
    final acapela = AcapelaTtsHandler();
    final initialized = await acapela.initialize(
      userId: 0x7a323547,
      password: 0x00302bc1,
      license: '"5917 0 G52z #COMMERCIAL#Abilia Norway"\n'
          'VimydOpXm@G7mAD\$VyO!eL%3JVAuNstBxpBi!gMZOXb7CZ6wq3i#\n'
          'V2%VyjWqtZliBRu%@pga5pAjKcadHfW4JhbwUUi7goHwjpIB\n'
          'RK\$@cHvZ!G9GsQ%lnEmu3S##',
      voicesPath: voicesPath,
    );
    if (initialized &&
        voiceDb.voice.isNotEmpty &&
        (await acapela.availableVoices).isNotEmpty) {
      await acapela.setVoice({'voice': voiceDb.voice});
      await acapela.setSpeechRate(voiceDb.speechRate);
    }
    _log.fine('Initialized $initialized');
    return acapela;
  }
}

class FlutterTtsHandler extends FlutterTts implements TtsInterface {
  static final Logger _log = Logger((FlutterTts).toString());

  static Future<FlutterTtsHandler> implementation() async {
    final tts = FlutterTtsHandler();

    if (Platform.isIOS) {
      await tts
          .setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ]);
    }

    await tts.awaitSpeakCompletion(true);

    tts.setStartHandler(() {
      _log.finest('start');
    });
    tts.setCompletionHandler(() {
      _log.finest('complete');
    });
    tts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      _log.finest(text);
      _log.finest('^'.padLeft(startOffset) + word);
    });
    tts.setErrorHandler((msg) {
      _log.warning('error: $msg');
    });

    return tts;
  }

  @override
  Future<List<Object?>> get availableVoices => Future.value(List.empty());
}
