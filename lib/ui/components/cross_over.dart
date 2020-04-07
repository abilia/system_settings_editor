import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CrossOver extends StatelessWidget {
  const CrossOver({
    Key key,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.fallbackWidth = 215.0,
    this.fallbackHeight = 215.0,
  }) : super(key: key);

  final Color color;
  final double strokeWidth;
  final double fallbackWidth;
  final double fallbackHeight;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: fallbackWidth,
      maxHeight: fallbackHeight,
      child: CustomPaint(
        size: Size.infinite,
        foregroundPainter: _CrossOverPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _CrossOverPainter extends CustomPainter {
  const _CrossOverPainter({
    this.color,
    this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final Rect rect = Offset.zero & size;
    final Path path = Path()
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
