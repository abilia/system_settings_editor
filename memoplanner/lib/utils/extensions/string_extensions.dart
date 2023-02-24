import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

extension SizeOfText on String {
  TextPainter textPainter(TextStyle style, double width, int? maxLines,
          {double scaleFactor = 1.0}) =>
      TextPainter(
        text: TextSpan(text: this, style: style),
        textScaleFactor: scaleFactor,
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width);

  TextRenderingSize calculateTextRenderSize({
    required BoxConstraints constraints,
    required TextStyle textStyle,
    int? maxLines,
    EdgeInsets padding = EdgeInsets.zero,
    double textScaleFactor = 1.0,
  }) {
    final width = constraints.maxWidth - padding.horizontal;
    final height = constraints.maxHeight - padding.vertical;
    final painter = textPainter(
      textStyle,
      width,
      maxLines,
      scaleFactor: textScaleFactor,
    );
    final numberOfLines = max(
      height ~/ painter.preferredLineHeight,
      painter.height ~/ painter.preferredLineHeight,
    );
    return TextRenderingSize(painter, numberOfLines);
  }
}

extension Replace on String {
  String get singleLine => replaceAll('-\n', '');
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}

class TextRenderingSize {
  final TextPainter textPainter;
  final int numberOfLines;
  const TextRenderingSize(
    this.textPainter,
    this.numberOfLines,
  );

  TextRenderingSize copyWith({
    TextPainter? textPainter,
    int? numberOfLines,
  }) =>
      TextRenderingSize(
          textPainter ?? this.textPainter, numberOfLines ?? this.numberOfLines);
}
