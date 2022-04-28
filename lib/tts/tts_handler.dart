import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:seagull/logging.dart';

abstract class TtsInterface {
  static Future<TtsInterface> implementation() async {
    // TODO if (Config.isMPGO)
    return FlutterTtsHandler();
    // ignore: dead_code
    final _log = Logger((TtsInterface).toString());
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
      _log.warning('No acapela voices available');
    }
    _log.fine('Acapela initialized $initialized');
    return acapela;
  }

  Future<dynamic> speak(String text);

  Future<dynamic> stop();

  Future<dynamic> pause();
}

class FlutterTtsHandler extends FlutterTts implements TtsInterface {}

class AcapelaTtsHandler extends AcapelaTts implements TtsInterface {}
