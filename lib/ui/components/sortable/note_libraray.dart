import 'package:flutter/material.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class LibraryNote extends StatelessWidget {
  final String content;
  const LibraryNote({Key key, @required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageHeight = 86.0;
    final imageWidth = 84.0;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: content,
        button: true,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () async {
              await Navigator.of(context).maybePop<String>(content);
            },
            borderRadius: borderRadius,
            child: Ink(
              width: imageWidth,
              height: imageHeight,
              decoration: whiteBoxDecoration,
              padding: const EdgeInsets.all(4.0),
              child: LayoutBuilder(builder: (context, constraints) {
                final textRenderSize = content.calulcateTextRenderSize(
                  constraints: constraints,
                  textStyle: abiliaTextTheme.caption,
                  textScaleFactor: MediaQuery.of(context).textScaleFactor,
                );
                return Stack(
                  children: <Widget>[
                    Lines(
                      lineHeight: textRenderSize.scaledLineHeight,
                      numberOfLines: 6,
                    ),
                    Text(
                      content,
                      maxLines: 7,
                      overflow: TextOverflow.fade,
                      style: abiliaTextTheme.caption,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
