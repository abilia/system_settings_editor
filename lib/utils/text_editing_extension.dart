import 'package:get_it/get_it.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';

class AbiliaTextEditingController extends TextEditingController {
  String lastText = '';
  final bool speakEveryWord;

  AbiliaTextEditingController({text, this.speakEveryWord = false})
      : super(text: text);

  @override
  set value(TextEditingValue newValue) {
    assert(
      !newValue.composing.isValid || newValue.isComposingRangeValid,
      'New TextEditingValue $newValue has an invalid non-empty composing range '
      '${newValue.composing}. It is recommended to use a valid composing range, '
      'even for readonly text fields',
    );
    super.value = newValue;
    if (shouldSpeakWord()) {
      final words = [...value.text.split(' ')].where((word) => word.isNotEmpty);
      GetIt.I<TtsInterface>().speak(words.last);
    }
    lastText = value.text;
  }

  bool shouldSpeakWord() {
    return (speakEveryWord &&
        text.endsWith(' ') &&
        !lastText.endsWith(' ') &&
        lastText != text);
  }
}
