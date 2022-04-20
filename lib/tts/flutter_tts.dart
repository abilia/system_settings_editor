import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:logging/logging.dart';

final _ttsLog = Logger('TTS');
Future<FlutterTts> flutterTts() async {
  final tts = FlutterTts();

  if (Platform.isIOS) {
    await tts.setSharedInstance(true);
    await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
    ]);
  }

  // await tts.awaitSpeakCompletion(true);

  tts.setStartHandler(() {
    _ttsLog.finest('start');
  });
  tts.setCompletionHandler(() {
    _ttsLog.finest('complete');
  });
  tts.setProgressHandler(
      (String text, int startOffset, int endOffset, String word) {
    _ttsLog.finest(text);
    _ttsLog.finest('^'.padLeft(startOffset) + word);
  });
  tts.setErrorHandler((msg) {
    _ttsLog.finest('error: $msg');
  });
  tts.setCancelHandler(() {
    _ttsLog.finest('cancel');
  });
  tts.setPauseHandler(() {
    _ttsLog.finest('pause');
  });
  tts.setContinueHandler(() {
    _ttsLog.finest('continue');
  });

  return tts;
}
