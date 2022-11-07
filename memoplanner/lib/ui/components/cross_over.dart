import 'package:memoplanner/ui/all.dart';

class CrossOver extends StatelessWidget {
  const CrossOver({
    Key? key,
    this.style = CrossOverStyle.darkDefault,
    this.applyCross = true,
    this.fallbackWidth,
    this.fallbackHeight,
    this.padding,
    this.child,
  }) : super(key: key);

  final CrossOverStyle style;
  final bool applyCross;
  final double? fallbackWidth, fallbackHeight;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: fallbackWidth ?? double.infinity,
        maxHeight: fallbackHeight ?? double.infinity,
      ),
      child: CustomPaint(
        size: Size.infinite,
        foregroundPainter: applyCross
            ? _CrossOverPainter(
                color: style.color,
                padding: padding,
              )
            : null,
        child: child,
      ),
    );
  }
}

class _CrossOverPainter extends CustomPainter {
  const _CrossOverPainter({
    required this.color,
    padding,
  }) : padding = padding ?? EdgeInsets.zero;

  final Color color;
  final EdgeInsets padding;

  @override
  void paint(Canvas canvas, Size size) {
    final rectSize = Size(
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = layout.crossOver.strokeWidth
      ..strokeCap = StrokeCap.round;
    final offset = Offset(padding.left, padding.top);
    final rect = offset & rectSize;
    final path = Path()
      ..addPolygon(<Offset>[rect.topRight, rect.bottomLeft], false)
      ..addPolygon(<Offset>[rect.topLeft, rect.bottomRight], false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CrossOverPainter oldPainter) {
    return oldPainter.color != color || oldPainter.padding != padding;
  }

  @override
  bool hitTest(Offset position) => false;
}

// Names are from the Figma component
enum CrossOverStyle {
  darkDefault,
  darkSecondary,
  lightDefault,
  lightSecondary,
}

extension CrossOverColor on CrossOverStyle {
  Color get color {
    switch (this) {
      case CrossOverStyle.darkDefault:
        return AbiliaColors.black;
      case CrossOverStyle.darkSecondary:
        return AbiliaColors.transparentBlack30;
      case CrossOverStyle.lightDefault:
        return AbiliaColors.white;
      case CrossOverStyle.lightSecondary:
        return AbiliaColors.transparentWhite30;
    }
  }
}
