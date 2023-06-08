import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
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
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onLongPress: _playTts,
        child: child,
      );

  Future<void> _playTts() async => GetIt.I<TtsHandler>().speak(data);
}
