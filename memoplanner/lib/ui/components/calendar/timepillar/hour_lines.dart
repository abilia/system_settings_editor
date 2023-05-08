import 'package:memoplanner/ui/all.dart';

class HourLines extends StatelessWidget {
  final int numberOfLines;
  final double hourHeight, width, strokeWidth;
  const HourLines({
    required this.hourHeight,
    required this.width,
    required this.strokeWidth,
    this.numberOfLines = 24,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          numberOfLines,
          (_) => SizedBox(
            height: hourHeight,
            child: DottedLine(
              dashColor: AbiliaColors.white135,
              width: width,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      );
}

class DottedLine extends StatelessWidget {
  final double width, strokeWidth;
  final Color dashColor;
  const DottedLine({
    required this.width,
    required this.strokeWidth,
    required this.dashColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: DashedLinePainter(
          dashColor: dashColor,
          width: width,
          strokeWidth: strokeWidth,
        ),
      );
}

class DashedLinePainter extends CustomPainter {
  final double width, dashWidth = 6, dashSpace = 6;
  final double offset;
  final Paint _paint;
  DashedLinePainter({
    required this.width,
    required double strokeWidth,
    required dashColor,
  })  : _paint = Paint()
          ..color = dashColor
          ..strokeWidth = strokeWidth,
        offset = strokeWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    for (double x = 0; x < width; x += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(x, offset),
        Offset(x + dashWidth, offset),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
