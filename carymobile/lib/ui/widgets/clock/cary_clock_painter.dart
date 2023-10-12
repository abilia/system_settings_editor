part of 'analog_clock.dart';

class CaryClockPainter extends CustomPainter {
  final DateTime _datetime;
  final TextStyle textStyle;
  final Color dialPlateColor, mainColor, minuteMarkColor;
  final bool showMinuteMark;

  CaryClockPainter(
    this._datetime, {
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
    ),
    this.dialPlateColor = Colors.transparent,
    this.mainColor = Colors.black,
    this.minuteMarkColor = Colors.grey,
    this.showMinuteMark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const borderFraction = 22 / 736;
    const numberFraction = borderFraction * 8;
    const fontFraction = borderFraction * 6;

    final radius = min(size.width, size.height) / 2;
    final borderWidth = radius * borderFraction;
    final numberOffset = radius * numberFraction;
    final numberRadius = radius - numberOffset;
    final knobRadius = borderWidth * 1.5;
    final knobPadding = knobRadius * 1.5;
    final fontSize = radius * fontFraction;

    canvas.translate(
      size.width / 2,
      size.height / 2,
    );
    if (showMinuteMark) {
      _paintMinuteMark(canvas, radius, numberOffset / 4, borderWidth / 2);
    }
    _paintHourText(
        canvas, numberRadius, textStyle.copyWith(fontSize: fontSize));
    _paintHourMark(canvas, radius, numberOffset / 2, borderWidth);

    final hourDial = hourHandEnd(numberRadius * 0.8);
    final minuteDial = minuteHandEnd(numberRadius);
    canvas
      ..drawCircle(
        const Offset(0, 0),
        radius,
        _borderPaint(borderWidth),
      )
      // Save layer to draw transparent inner ring later
      ..saveLayer(Rect.largest, Paint())
      // Hour dial
      ..drawLine(
        const Offset(0, 0),
        hourDial,
        strokePainter(borderWidth),
      )
      ..drawPath(
        getTrianglePath(hourDial, knobRadius, borderWidth),
        dialPaint(),
      )
      // Minute dial
      ..drawLine(
        const Offset(0, 0),
        minuteHandEnd(numberRadius),
        strokePainter(borderWidth),
      )
      ..drawPath(
        getTrianglePath(minuteDial, knobRadius, borderWidth),
        dialPaint(),
      )
      // Center knob
      ..drawCircle(
        const Offset(0, 0),
        knobPadding,
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore()
      ..drawCircle(
        const Offset(0, 0),
        knobRadius,
        Paint()..blendMode = BlendMode.src,
      );
  }

  Path getTrianglePath(Offset p, double baseWidth, double topWidth) {
    // Calculate the direction vector
    final magnitude = p.distance;
    final normalizedDirection = Offset(p.dx / magnitude, p.dy / magnitude);
    final base1 = Offset(
          normalizedDirection.dy,
          -normalizedDirection.dx,
        ) *
        baseWidth;
    final base2 = Offset(
          -normalizedDirection.dy,
          normalizedDirection.dx,
        ) *
        baseWidth;
    final top1 = Offset(
      p.dx + (topWidth / 2) * normalizedDirection.dy,
      p.dy - (topWidth / 2) * normalizedDirection.dx,
    );
    final top2 = Offset(
      p.dx - (topWidth / 2) * normalizedDirection.dy,
      p.dy + (topWidth / 2) * normalizedDirection.dx,
    );

    return Path()
      ..lineTo(base1.dx, base1.dy)
      ..lineTo(top1.dx, top1.dy)
      ..lineTo(top2.dx, top2.dy)
      ..lineTo(base2.dx, base2.dy);
  }

  Paint dialPaint() {
    return Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;
  }

  Paint _borderPaint(double strokeWidth) {
    return Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
  }

  void _paintHourText(Canvas canvas, double radius, TextStyle textStyle) {
    for (var i = 0; i < 12; i++) {
      final angle = i * 30.0;
      final radians = getRadians(angle);
      final hourNumberX = cos(radians) * radius;
      final hourNumberY = sin(radians) * radius;
      canvas
        ..save()
        ..translate(hourNumberX, hourNumberY);
      final hour = i > 9 ? i - 9 : i + 3;
      final hourTextPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        text: TextSpan(
          text: '$hour',
          style: textStyle,
        ),
      );
      hourTextPainter
        ..layout()
        ..paint(
          canvas,
          Offset(-hourTextPainter.width / 2, -hourTextPainter.height / 2),
        );
      canvas.restore();
    }
  }

  void _paintHourMark(
    Canvas canvas,
    double outerRadius,
    double length,
    double strokeWidth,
  ) {
    for (var i = 0; i < 12; i++) {
      final radians = getRadians(i * 30.0);
      final xAngle = cos(radians);
      final yAngle = sin(radians);
      final start = Offset(xAngle * outerRadius, yAngle * outerRadius);
      final innerRadius = outerRadius - length;
      final end = Offset(xAngle * innerRadius, yAngle * innerRadius);
      canvas.drawLine(
        start,
        end,
        strokePainter(strokeWidth),
      );
    }
  }

  void _paintMinuteMark(
    Canvas canvas,
    double outerRadius,
    double length,
    double strokeWidth,
  ) {
    for (var i = 0; i < 60; i++) {
      final radians = getRadians(i * 6.0);
      final xAngle = cos(radians);
      final yAngle = sin(radians);
      final start = Offset(xAngle * outerRadius, yAngle * outerRadius);
      final innerRadius = outerRadius - length;
      final end = Offset(xAngle * innerRadius, yAngle * innerRadius);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = minuteMarkColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth,
      );
    }
  }

  Offset hourHandEnd(double radius) {
    final hourAngle = _datetime.hour - 3;
    final minuteAngle = _datetime.minute / 60;
    final angle = hourAngle + minuteAngle;
    final radians = getRadians(angle * 30);
    return Offset(
      cos(radians) * radius,
      sin(radians) * radius,
    );
  }

  Offset minuteHandEnd(double radius) {
    final angle = _datetime.minute - 15.0;
    final radians = getRadians(angle * 6.0);
    return Offset(
      cos(radians) * radius,
      sin(radians) * radius,
    );
  }

  Paint strokePainter(double strokeWidth) {
    return Paint()
      ..color = mainColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
  }

  @override
  bool shouldRepaint(CaryClockPainter oldDelegate) {
    return _datetime != oldDelegate._datetime ||
        dialPlateColor != oldDelegate.dialPlateColor ||
        mainColor != oldDelegate.mainColor ||
        minuteMarkColor != oldDelegate.minuteMarkColor ||
        textStyle != oldDelegate.textStyle;
  }

  static double getRadians(double angle) {
    return angle * pi / 180;
  }
}
