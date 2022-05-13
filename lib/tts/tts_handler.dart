import 'dart:io';

import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:seagull/config.dart';
import 'package:seagull/logging.dart';

abstract class TtsInterface {
  static Future<TtsInterface> implementation() async {
    if (Config.isMPGO) return await FlutterTtsHandler.implementation();
    return await AcapelaTtsHandler.implementation();
  }

  Future<dynamic> speak(String text);

  Future<dynamic> stop();

  Future<dynamic> pause();
}

class AcapelaTtsHandler extends AcapelaTts implements TtsInterface {
  static final Logger _log = Logger((AcapelaTts).toString());

  static Future<AcapelaTtsHandler> implementation() async {
    final acapela = AcapelaTtsHandler();
    bool initialized = await acapela.setLicense(
      0x31364e69,
      0x004dfba3,
      '"4877 0 iN61 #EVALUATION#Abilia-Solna-Sweden"\n'
      'Uulz3XChrD9pVq!udAjvoOjtUunooL3FMZa6plK6RhhwiTzf\$Qaorlmwdyh#\n'
      'X6XAIrmYSRSUMSSNL25d7kHMXTKDS@Nlg2kl@YK4RsFVGPDX\n'
      'TqUDZO3UZgZhyJFRbfKSpQ##\n',
    );
    List<Object?> voices = await acapela.availableVoices;
    if (voices.isNotEmpty) {
      await acapela.setVoice(voices.first.toString());
    } else {
      _log.warning('No voices available');
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
      await tts.setSharedInstance(true);
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
}
