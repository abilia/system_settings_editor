import 'package:seagull/ui/all.dart';

class CrossOver extends StatelessWidget {
  const CrossOver({
    Key? key,
    this.type = CrossOverType.darkDefault,
    this.applyCross = true,
    this.colorOverride,
    this.fallbackWidth,
    this.fallbackHeight,
    this.padding,
    this.child,
  }) : super(key: key);

  final CrossOverType type;
  final bool applyCross;
  final Color? colorOverride;
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
                color: colorOverride ?? type.color,
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
    size = Size(
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = layout.crossOver.strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Offset(padding.left, padding.top) & size;
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
enum CrossOverType {
  darkDefault,
  darkSecondary,
  lightDefault,
  lightSecondary,
}

extension CrossOverColor on CrossOverType {
  Color get color {
    switch (this) {
      case CrossOverType.darkDefault:
        return AbiliaColors.black;
      case CrossOverType.darkSecondary:
        return AbiliaColors.transparentBlack30;
      case CrossOverType.lightDefault:
        return AbiliaColors.white;
      case CrossOverType.lightSecondary:
        return AbiliaColors.transparentWhite30;
    }
  }
}
