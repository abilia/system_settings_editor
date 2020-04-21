import 'dart:math';

import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class NoteBlock extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  const NoteBlock({
    Key key,
    @required this.text,
    @required this.height,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = abiliaTextTheme.body2;
    final size = _textSize(text, textStyle, width);
    final lineHeight = textStyle.fontSize * textStyle.height;
    final numberOfLines = max(height, size.height) / lineHeight;
    return Container(
      child: Stack(children: [
        Text(text, style: textStyle),
        Lines(
          lineHeight: lineHeight,
          numberOfLines: numberOfLines.ceil(),
        ),
      ]),
    );
  }

  Size _textSize(String text, TextStyle style, double width) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);
    return textPainter.size;
  }
}

class Lines extends StatelessWidget {
  final double lineHeight;
  final int numberOfLines;
  const Lines({
    Key key,
    @required this.lineHeight,
    @required this.numberOfLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final line = Padding(
        padding: EdgeInsets.only(top: this.lineHeight),
        child: Divider(
          color: AbiliaColors.white[120],
          height: 0,
        ));

    return Column(
      children: List.generate(this.numberOfLines, (_) => line).toList(),
    );
  }
}
