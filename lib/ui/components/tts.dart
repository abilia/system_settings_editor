import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/tts/tts_interface.dart';

class Tts extends StatelessWidget {
  final Text child;

  const Tts({
    Key? key,
    required this.child,
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
    Key? key,
    required this.child,
    this.data,
    this.onLongPress,
  })  : assert(data != null || onLongPress != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onLongPress: settingsState.textToSpeech &&
                  (onLongPress != null || data != null)
              ? _playTts
              : null,
          child: child,
        ),
      );

  void _playTts() async {
    GetIt.I<TtsInterface>().play(onLongPress?.call() ?? data ?? '');
  }
}
