import 'dart:ui';

import 'package:flutter/rendering.dart';

extension RemoveLeading on String {
  String removeLeadingZeros() => replaceFirst(RegExp('^0+(?!\$)'), '');
}

extension SizeOfText on String {
  Size textSize(TextStyle style, double width, {double scaleFactor = 1.0}) {
    final textPainter = TextPainter(
        text: TextSpan(text: this, style: style),
        textScaleFactor: scaleFactor,
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);
    return textPainter.size;
  }
}
