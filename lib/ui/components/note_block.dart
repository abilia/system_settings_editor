import 'dart:math';

import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class NoteBlock extends StatelessWidget {
  final String text;
  const NoteBlock({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final scaleFactor = MediaQuery.of(context).textScaleFactor;
        final textStyle = abiliaTextTheme.body2;
        final textSize = text.textSize(textStyle, constraints.maxWidth);
        final scaledTextHeight = textSize.height * scaleFactor;
        final scaledLineHeight =
            textStyle.fontSize * textStyle.height * scaleFactor;
        final numberOfLines =
            max(constraints.maxHeight, scaledTextHeight) / scaledLineHeight;
        return Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: Attachment.padding,
              child: Stack(
                children: [
                  Text(text, style: textStyle),
                  Lines(
                    lineHeight: scaledLineHeight,
                    numberOfLines: numberOfLines.ceil(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
