import 'dart:ui';

import 'package:flutter/rendering.dart';

extension RemoveLeading on String {
  String removeLeadingZeros() => this.replaceFirst(RegExp('^0+(?!\$)'), '');
}

extension SizeOfText on String {
  Size textSize(TextStyle style, double width) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: this, style: style),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);
    return textPainter.size;
  }
}
