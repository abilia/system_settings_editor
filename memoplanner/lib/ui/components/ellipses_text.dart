import 'package:memoplanner/ui/all.dart';

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
