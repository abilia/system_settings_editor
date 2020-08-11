import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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

  TextRenderingSize calulcateTextRenderSize({
    @required BoxConstraints constraints,
    @required TextStyle textStyle,
    @required EdgeInsets padding,
    double textScaleFactor = 1.0,
  }) {
    final width = constraints.maxWidth - padding.vertical;
    final height = constraints.maxHeight - padding.horizontal;
    final sizeOfText = textSize(textStyle, width);
    final scaledTextHeight = sizeOfText.height * textScaleFactor;
    final scaledLineHeight =
        textStyle.fontSize * textStyle.height * textScaleFactor;
    final numberOfLines =
        max(height ~/ scaledLineHeight, scaledTextHeight ~/ scaledLineHeight);
    return TextRenderingSize(numberOfLines, scaledLineHeight, scaledTextHeight);
  }
}

class TextRenderingSize {
  final int numberOfLines;
  final double scaledLineHeight, scaledTextHeight;
  const TextRenderingSize(
      this.numberOfLines, this.scaledLineHeight, this.scaledTextHeight);
}
