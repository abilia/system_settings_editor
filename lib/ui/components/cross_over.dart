import 'package:seagull/ui/all.dart';

class CrossOver extends StatelessWidget {
  const CrossOver({
    Key? key,
    this.color,
    this.strokeWidth,
    this.fallbackWidth,
    this.fallbackHeight,
  }) : super(key: key);

  final Color? color;
  final double? strokeWidth;
  final double? fallbackWidth;
  final double? fallbackHeight;
  static final double defaultStrokeWidth =
      layout.commonCalendar.crossOverStrokeWidth;
  static final double defaultFallbackWidth =
      layout.commonCalendar.crossOverFallback;
  static final double defaultFallbackHeight =
      layout.commonCalendar.crossOverFallback;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: fallbackWidth ?? defaultFallbackWidth,
      maxHeight: fallbackHeight ?? defaultFallbackHeight,
      child: CustomPaint(
        size: Size.infinite,
        foregroundPainter: _CrossOverPainter(
          color: color ?? const Color(0xFF000000),
          strokeWidth: strokeWidth ?? defaultStrokeWidth,
        ),
      ),
    );
  }
}

class _CrossOverPainter extends CustomPainter {
  const _CrossOverPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rect = Offset.zero & size;
    final path = Path()
      ..addPolygon(<Offset>[rect.topRight, rect.bottomLeft], false)
      ..addPolygon(<Offset>[rect.topLeft, rect.bottomRight], false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CrossOverPainter oldPainter) {
    return oldPainter.color != color || oldPainter.strokeWidth != strokeWidth;
  }

  @override
  bool hitTest(Offset position) => false;
}

class WithCrossOver extends StatelessWidget {
  final Widget child;
  final bool applyCross;
  final EdgeInsets crossOverPadding;
  final Color? color;
  const WithCrossOver({
    Key? key,
    required this.child,
    required this.applyCross,
    this.crossOverPadding = EdgeInsets.zero,
    this.color = const Color(0xFF000000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (applyCross)
          Padding(
            padding: crossOverPadding,
            child: CrossOver(
              color: color ?? const Color(0xFF000000),
            ),
          ),
      ],
    );
  }
}
