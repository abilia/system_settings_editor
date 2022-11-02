import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';

import 'package:seagull/tts/tts_handler.dart';

class SpokenTextEditController extends TextEditingController {
  static TextEditingController ifApplicable(BuildContext context,
          {String? text}) =>
      Config.isMP && context.read<SpeechSettingsCubit>().state.speakEveryWord
          ? SpokenTextEditController._(
              text: text,
              onNewWord: GetIt.I<TtsInterface>().speak,
            )
          : TextEditingController(text: text);

  final void Function(String) onNewWord;

  SpokenTextEditController._({
    required this.onNewWord,
    String? text,
  }) : super(text: text);

  @override
  set value(TextEditingValue newValue) {
    final newWord = shouldSpeakWord(newValue);
    if (newWord != null) onNewWord(newWord);
    super.value = newValue;
  }

  String? shouldSpeakWord(TextEditingValue newValue) {
    if (newValue.text == value.text) return null;

    final cursor = newValue.selection.base.offset;
    if (newValue.isComposingRangeValid && newValue.composing.start != cursor) {
      return null;
    }

    if (value.isComposingRangeValid) {
      final start = value.composing.start;
      // this does not work well when
      // the cursor is in middle of word we composing and we delete a character
      // then the word gets out of composing
      // and we speak the first part of the word
      // the alternative is to check if (value.composing.end < cursor)
      // but then if we correct a misspelled word
      // that is longer then the correctly spelled
      // tts will not be triggerd
      if (start < cursor) return newValue.text.substring(start, cursor);
    }

    final newWord = newValue.text.split(' ').where((s) => s.isNotEmpty).length >
        value.text.split(' ').where((s) => s.isNotEmpty).length;
    if (newWord) {
      final words = newValue.text
          .substring(0, cursor)
          .split(' ')
          .where((w) => w.isNotEmpty);
      if (words.isNotEmpty) return words.last;
    }

    return null;
  }
}
