import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/tts/tts_handler.dart';

class Tts extends StatelessWidget {
  final Text child;

  const Tts({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _Tts(
        data: child.semanticsLabel ?? child.data,
        child: child,
      );

  static Widget data({
    required data,
    required Widget child,
  }) =>
      _Tts(data: data, child: child);

  static Widget longPress(
    String Function()? onLongPress, {
    required Widget child,
  }) =>
      _Tts(onLongPress: onLongPress, child: child);

  static Widget fromSemantics(
    SemanticsProperties properties, {
    required Widget child,
  }) {
    final semantics =
        Semantics.fromProperties(properties: properties, child: child);
    if (properties.label?.isNotEmpty == true) {
      return _Tts(
        data: properties.label,
        child: semantics,
      );
    }
    return semantics;
  }
}

class _Tts extends StatelessWidget {
  final Widget child;
  final String? data;
  final String Function()? onLongPress;

  const _Tts({
    required this.child,
    this.data,
    this.onLongPress,
    Key? key,
  })  : assert(data != null || onLongPress != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SpeechSettingsCubit, SpeechSettingsState, bool>(
        selector: (state) => state.textToSpeech,
        builder: (context, textToSpeech) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onLongPress: textToSpeech && (onLongPress != null || data != null)
              ? _playTts
              : null,
          child: child,
        ),
      );

  Future<void> _playTts() async =>
      GetIt.I<TtsInterface>().speak(onLongPress?.call() ?? data ?? '');
}
