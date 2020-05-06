import 'dart:math';

import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

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
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    final textStyle = abiliaTextTheme.body2;
    final textSize =
        text.textSize(textStyle, width, scaleFactor: scaleFactor).height;
    final scaledLineHeight =
        textStyle.fontSize * textStyle.height * scaleFactor;
    final numberOfLines = max(height, textSize) / scaledLineHeight;
    return Container(
      child: Stack(children: [
        Text(text, style: textStyle),
        Lines(
          lineHeight: scaledLineHeight,
          numberOfLines: numberOfLines.ceil(),
        ),
      ]),
    );
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
