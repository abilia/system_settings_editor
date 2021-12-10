import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

extension SizeOfText on String {
  TextPainter textPainter(TextStyle style, double width,
          {double scaleFactor = 1.0}) =>
      TextPainter(
          text: TextSpan(text: this, style: style),
          textScaleFactor: scaleFactor,
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);

  TextRenderingSize calulcateTextRenderSize({
    required BoxConstraints constraints,
    required TextStyle textStyle,
    EdgeInsets padding = EdgeInsets.zero,
    double textScaleFactor = 1.0,
  }) {
    final width = constraints.maxWidth - padding.horizontal;
    final height = constraints.maxHeight - padding.vertical;
    final painter = textPainter(
      textStyle,
      width,
      scaleFactor: textScaleFactor,
    );
    final numberOfLines = max(
      height ~/ painter.preferredLineHeight,
      painter.height ~/ painter.preferredLineHeight,
    );
    return TextRenderingSize(painter, numberOfLines);
  }
}

extension UriExtension on String {
  Uri toUri() {
    return Uri.parse(this);
  }
}

extension Replace on String {
  String get singleLine => replaceAll('-\n', '');
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}

class TextRenderingSize {
  final int numberOfLines;
  final TextPainter textPainter;
  double get scaledLineHeight => textPainter.preferredLineHeight;
  double get scaledTextHeight => textPainter.height;
  const TextRenderingSize(
    this.textPainter,
    this.numberOfLines,
  );
  @override
  String toString() =>
      'TextRenderingSize: {numberOfLines: $numberOfLines, scaledTextHeight: $scaledTextHeight, scaledLineHeight: $scaledLineHeight}';
}
