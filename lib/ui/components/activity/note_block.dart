import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class NoteBlock extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Text? textWidget;
  final ScrollController? scrollController;
  const NoteBlock({
    Key? key,
    this.text = '',
    this.textStyle,
    this.textWidget,
    this.scrollController,
  }) : super(key: key);

  @override
  _NoteBlockState createState() => _NoteBlockState(
      scrollController ?? ScrollController(), textStyle ?? bodyText1);
}

class _NoteBlockState extends State<NoteBlock> {
  _NoteBlockState(this.controller, this.textStyle);
  final ScrollController controller;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final text = widget.textWidget;
    return Tts.data(
      data: text?.data ?? '',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final textRenderingSize = widget.text.calulcateTextRenderSize(
            constraints: constraints,
            textStyle: textStyle,
            padding: Attachment.padding,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
          );
          return DefaultTextStyle(
            style: textStyle,
            child: VerticalScrollArrows(
              controller: controller,
              child: SingleChildScrollView(
                padding: Attachment.padding,
                controller: controller,
                child: Stack(
                  children: [
                    if (text != null) text,
                    Lines(
                      lineHeight: textRenderingSize.scaledLineHeight,
                      numberOfLines: textRenderingSize.numberOfLines,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Lines extends StatelessWidget {
  final double lineHeight;
  final int numberOfLines;
  const Lines({
    Key? key,
    required this.lineHeight,
    required this.numberOfLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final line = Padding(
      padding: EdgeInsets.only(top: lineHeight),
      child: const Divider(),
    );

    return Column(
      children: List.generate(numberOfLines, (_) => line).toList(),
    );
  }
}
