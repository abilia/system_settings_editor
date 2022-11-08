import 'package:memoplanner/ui/all.dart';

class EllipsesText extends Text {
  const EllipsesText(
    super.data, {
    super.style,
    super.key,
    super.maxLines,
    super.textAlign,
  });

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

      final maxLines = constraints.maxHeight ~/ lineHeight;

      return Text(
        data ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines.clamp(1, super.maxLines ?? 1),
        style: style,
      );
    });
  }
}
