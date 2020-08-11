import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class NoteBlock extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Widget child;
  final ScrollController scrollController;
  const NoteBlock({
    Key key,
    this.text = '',
    this.textStyle,
    this.child,
    this.scrollController,
  }) : super(key: key);

  @override
  _NoteBlockState createState() => _NoteBlockState(
      scrollController ?? ScrollController(),
      textStyle ?? abiliaTextTheme.bodyText1);
}

class _NoteBlockState extends State<NoteBlock> {
  _NoteBlockState(this.controller, this.textStyle);
  final ScrollController controller;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textRenderingSize = widget.text.calulcateTextRenderSize(
          constraints: constraints,
          textStyle: textStyle,
          padding: Attachment.padding,
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
        );
        return DefaultTextStyle(
          style: textStyle,
          child: Stack(
            children: <Widget>[
              CupertinoScrollbar(
                controller: controller,
                child: SingleChildScrollView(
                  padding: Attachment.padding,
                  controller: controller,
                  child: Stack(
                    children: [
                      if (widget.child != null) widget.child,
                      Lines(
                        lineHeight: textRenderingSize.scaledLineHeight,
                        numberOfLines: textRenderingSize.numberOfLines,
                      ),
                    ],
                  ),
                ),
              ),
              ArrowUp(controller: controller),
              ArrowDown(controller: controller),
            ],
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
