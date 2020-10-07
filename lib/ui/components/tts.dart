import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';

class Tts extends StatelessWidget {
  final Widget child;
  final String data;

  const Tts({
    Key key,
    @required this.child,
    this.data,
  })  : assert(data != null || child is Text),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    final _text = (Text text) => text.semanticsLabel ?? text.data;
    var label = data ?? _text(child);
    return _Tts(
      data: label,
      child: child,
    );
  }

  static Widget fromSemantics(
    SemanticsProperties properties, {
    @required Widget child,
  }) {
    final semantics =
        Semantics.fromProperties(properties: properties, child: child);
    if (properties.label?.isNotEmpty == true) {
      return _Tts(data: properties.label, child: semantics);
    }
    return semantics;
  }
}

class _Tts extends StatelessWidget {
  final Widget child;
  final String data;

  const _Tts({Key key, this.child, @required this.data})
      : assert(data != null),
        super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onLongPress: () {
            if (settingsState.textToSpeech) GetIt.I<FlutterTts>().speak(data);
          },
          child: child,
        ),
      );
}
