import 'dart:io';

import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logging/logging.dart';

enum TtsType {
  acapela,
  flutter,
}

abstract class TtsHandler {
  static Future<TtsHandler> implementation({
    required String voicesPath,
    required String voice,
    required double speechRate,
    required TtsType type,
  }) async {
    try {
      if (type == TtsType.acapela) {
        return await AcapelaTtsHandler.implementation(
          voicesPath: voicesPath,
          voice: voice,
          speechRate: speechRate,
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

  Future<bool> get isSpeaking;
}

class AcapelaTtsHandler extends AcapelaTts implements TtsHandler {
  static final Logger _log = Logger((AcapelaTts).toString());

  static Future<AcapelaTtsHandler> implementation({
    required String voicesPath,
    required String voice,
    required double speechRate,
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
        voice.isNotEmpty &&
        (await acapela.availableVoices).isNotEmpty) {
      await acapela.setVoice({'voice': voice});
      await acapela.setSpeechRate(speechRate);
    }
    _log.fine('Initialized $initialized');
    return acapela;
  }
}

class FlutterTtsHandler extends FlutterTts implements TtsHandler {
  static final Logger _log = Logger((FlutterTts).toString());

  bool _speaking = false;
  static Future<FlutterTtsHandler> implementation() async {
    final tts = FlutterTtsHandler();

    if (Platform.isIOS) {
      await tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playAndRecord,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
      );
    }

    await tts.awaitSpeakCompletion(true);

    tts
      ..setStartHandler(() {
        tts._speaking = true;
        _log.finest('start');
      })
      ..setCompletionHandler(() {
        tts._speaking = false;
        _log.finest('complete');
      })
      ..setProgressHandler(
          (String text, int startOffset, int endOffset, String word) => _log
            ..finest(text)
            ..finest('^'.padLeft(startOffset) + word))
      ..setErrorHandler((msg) {
        tts._speaking = false;
        _log.warning('error: $msg');
      });

    return tts;
  }

  @override
  Future<List<Object?>> get availableVoices => Future.value(List.empty());

  @override
  Future<bool> get isSpeaking async => _speaking;
}
