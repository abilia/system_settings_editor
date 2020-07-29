import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class NoteBlock extends StatefulWidget {
  final String text;
  const NoteBlock({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  _NoteBlockState createState() => _NoteBlockState(ScrollController());
}

class _NoteBlockState extends State<NoteBlock> {
  final ScrollController controller;

  _NoteBlockState(this.controller);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = constraints.maxWidth - Attachment.padding.vertical;
        final height = constraints.maxHeight - Attachment.padding.horizontal;
        final scaleFactor = MediaQuery.of(context).textScaleFactor;
        final textStyle = abiliaTextTheme.bodyText1;
        final textSize = widget.text.textSize(textStyle, width);
        final scaledTextHeight = textSize.height * scaleFactor;
        final scaledLineHeight =
            textStyle.fontSize * textStyle.height * scaleFactor;
        final numberOfLines = max(
            height ~/ scaledLineHeight, scaledTextHeight ~/ scaledLineHeight);
        return Stack(
          children: <Widget>[
            CupertinoScrollbar(
              controller: controller,
              child: SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: Attachment.padding,
                  child: Stack(
                    children: [
                      if (widget.text.isEmpty)
                        Text(Translator.of(context).translate.typeSomething,
                            style: textStyle.copyWith(
                                color: const Color(0xff747474)))
                      else
                        Text(widget.text, style: textStyle),
                      Lines(
                        lineHeight: scaledLineHeight,
                        numberOfLines: numberOfLines,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ArrowUp(controller: controller),
            ArrowDown(controller: controller),
          ],
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
        padding: EdgeInsets.only(top: lineHeight),
        child: Divider(
          color: AbiliaColors.white120,
          height: 0,
        ));

    return Column(
      children: List.generate(numberOfLines, (_) => line).toList(),
    );
  }
}
