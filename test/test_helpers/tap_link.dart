import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension TapLink on CommonFinders {
  bool _tapTextSpan(RichText richText, String text) {
    return !richText.text.visitChildren(
      (InlineSpan visitor) {
        if (visitor is TextSpan && visitor.text == text) {
          final recognizer = visitor.recognizer;
          if (recognizer is TapGestureRecognizer) {
            final onTap = recognizer.onTap;
            if (onTap != null) {
              onTap();
              return false;
            }
          }
        }
        return true;
      },
    );
  }

  Finder tapTextSpan(String text) {
    return byWidgetPredicate(
      (widget) => widget is RichText && _tapTextSpan(widget, text),
    );
  }
}
