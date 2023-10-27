import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Tts extends StatelessWidget {
  final Text child;

  const Tts({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _Tts(
        data: child.semanticsLabel ?? child.data,
        child: child,
      );

  static Widget data({
    required String data,
    required Widget child,
  }) =>
      _Tts(data: data, child: child);
}

class _Tts extends StatelessWidget {
  final Widget child;
  final String? data;
  final String Function()? onTap;

  const _Tts({
    required this.child,
    this.data,
    this.onTap,
  }) : assert(data != null || onTap != null);

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onTap: (onTap != null || data != null) ? _playOrStopTts : null,
        child: child,
      );

  Future<void> _playOrStopTts() async {
    final tts = GetIt.I<TtsHandler>();
    final isSpeaking = await tts.isSpeaking;
    if (isSpeaking) return await tts.stop();
    await tts.speak(onTap?.call() ?? data ?? '');
  }
}
