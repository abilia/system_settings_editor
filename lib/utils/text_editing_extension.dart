import 'package:get_it/get_it.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';

extension TextEditingExtension on TextEditingController {
  void speakEveryWordListener() {
    final text = this.text;
    if (text.endsWith(' ')) {
      final words = [...text.split(' ')].where((word) => word.isNotEmpty);
      GetIt.I<TtsInterface>().speak(words.last);
    }
  }
}
