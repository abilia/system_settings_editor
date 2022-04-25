import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsInterface {
  Future<dynamic> speak(String text);

  Future<dynamic> stop();

  Future<dynamic> pause();

  Future<dynamic> resume();
}

class FlutterTtsHandler implements TtsInterface {
  final FlutterTts flutterTts;

  FlutterTtsHandler(this.flutterTts);

  @override
  Future<dynamic> pause() async {
    return flutterTts.pause();
  }

  @override
  Future<dynamic> speak(String text) async {
    return flutterTts.speak(text);
  }

  @override
  Future<dynamic> stop() async {
    return flutterTts.stop();
  }

  @override
  Future<dynamic> resume() async {}
}

class AcapelaTtsHandler implements TtsInterface {
  AcapelaTtsHandler({initialize = false}) {
    if (initialize) {
      setLicense();
    }
  }

  Future<dynamic> setLicense() async {
    return await AcapelaTts.setLicense(0x31364e69, 0x004dfba3,
        '"4877 0 iN61 #EVALUATION#Abilia-Solna-Sweden"\nUulz3XChrD9pVq!udAjvoOjtUunooL3FMZa6plK6RhhwiTzf\$Qaorlmwdyh#\nX6XAIrmYSRSUMSSNL25d7kHMXTKDS@Nlg2kl@YK4RsFVGPDX\nTqUDZO3UZgZhyJFRbfKSpQ##\n');
  }

  @override
  Future<dynamic> pause() async {
    return await AcapelaTts.pause();
  }

  @override
  Future<dynamic> speak(String text) async {
    return await AcapelaTts.speak(text);
  }

  @override
  Future<dynamic> stop() async {
    return await AcapelaTts.stop();
  }

  @override
  Future<dynamic> resume() async {
    return await AcapelaTts.resume();
  }
}
