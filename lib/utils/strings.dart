import 'dart:ui';

import 'package:flutter/rendering.dart';

extension RemoveLeading on String {
  String removeLeadingZeros() => this.replaceFirst(RegExp('^0+(?!\$)'), '');
}

extension SizeOfText on String {
  Size textSize(TextStyle style, double width, {double scaleFactor = 1.0}) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: this, style: style),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);
    return textPainter.size * scaleFactor;
  }
}
