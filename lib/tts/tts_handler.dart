import 'package:acapela_tts/acapela_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/config.dart';
import 'package:seagull/logging.dart';

abstract class TtsInterface {
  static Future<TtsInterface> implementation() async {
    if (Config.isMPGO) return FlutterTtsHandler();
    final _log = Logger((TtsInterface).toString());
    final acapela = AcapelaTtsHandler();
    bool initialized = await acapela.initialize(
      userId: 0x7a323547,
      password: 0x00302bc1,
      license:
          '"5917 0 G52z #COMMERCIAL#Abilia Norway"\nVimydOpXm@G7mAD\$VyO!eL%3JVAuNstBxpBi!gMZOXb7CZ6wq3i#\nV2%VyjWqtZliBRu%@pga5pAjKcadHfW4JhbwUUi7goHwjpIB\nRK\$@cHvZ!G9GsQ%lnEmu3S##',
      voicesPath: (await getApplicationSupportDirectory()).path,
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
