import 'package:memoplanner/ui/all.dart';

// In order for TextOverflow.ellipses to show the ellipses on a Text,
// the provided maxLines value can't be bigger than the number of lines
// that can fit in the parent Widget. If for example 3 lines of text
// can fit but maxLines is set 4, then instead of ending the third line of text
// with an ellipses the text is clipped. This widget solves this by calculating
// the max number of lines that can fit and clamps the given maxLines to
// make sure ellipses is always shown if text overflows.
class EllipsesText extends StatelessWidget {
  const EllipsesText(
    this.data, {
    this.tts = false,
    this.style,
    this.maxLines,
    this.textAlign,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool tts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final lineHeight = (TextPainter(
        text: TextSpan(
          text: '',
          style: style,
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout())
          .height;

      final maxLinesFitting = constraints.maxHeight ~/ lineHeight;

      final text = Text(
        data,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLinesFitting.clamp(1, maxLines ?? 1),
        style: style,
        textAlign: textAlign,
      );

      return tts ? Tts(child: text) : text;
    });
  }
}
