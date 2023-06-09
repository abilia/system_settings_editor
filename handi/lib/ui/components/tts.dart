import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/bloc/settings_cubit.dart';
import 'package:handi/models/settings/handi_settings.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Tts extends StatelessWidget {
  final Widget child;
  final String data;

  const Tts({
    required this.child,
    required this.data,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, HandiSettings, bool>(
        selector: (state) => state.textToSpeech,
        builder: (context, textToSpeech) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onLongPress: textToSpeech ? _playTts : null,
          child: child,
        ),
      );

  Future<void> _playTts() async => GetIt.I<TtsHandler>().speak(data);
}
