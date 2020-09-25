import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:get_it/get_it.dart';

class Tts extends StatelessWidget {
  final Widget child;
  final String data;
  final SemanticsProperties semantics;

  const Tts({
    Key key,
    this.child,
    this.semantics,
    this.data,
  })  : assert(semantics != null || data != null || child is Text),
        assert(semantics == null || data == null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    var wrapped = child;
    var label = data;
    if (wrapped is Text && data == null && semantics?.label == null) {
      label = wrapped.semanticsLabel ?? wrapped.data;
    }

    if (semantics != null) {
      wrapped = Semantics.fromProperties(
        properties: semantics,
        child: wrapped,
      );
      if (semantics.label != null) {
        label = semantics.label;
      }
    }
    assert(label?.isNotEmpty == true,
        'either provide a Text widge, a sematics label or data');
    return _Tts(
      data: label,
      child: wrapped,
    );
  }
}

class _Tts extends StatelessWidget {
  final Widget child;
  final String data;

  const _Tts({Key key, this.child, @required this.data})
      : assert(data != null),
        super(key: key);
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onLongPress: () => GetIt.I<FlutterTts>().speak(data),
        child: child,
      );
}
