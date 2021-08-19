import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';

class Tts extends StatelessWidget {
  final Widget child;
  final String? data;

  const Tts({
    Key? key,
    this.data,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = child;
    if (c is Text) {
      _Tts(
        data: c.semanticsLabel ?? c.data,
        child: c,
      );
    }
    return _Tts(data: data, child: child);
  }

  static Widget longPress(
    String Function()? onLongPress, {
    required Widget child,
  }) =>
      _Tts(
        onLongPress: onLongPress,
        child: child,
      );

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
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onLongPress: settingsState.textToSpeech
              ? () => GetIt.I<FlutterTts>().speak(onLongPress?.call() ?? data!)
              : null,
          child: child,
        ),
      );
}
