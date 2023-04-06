import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:memoplanner/ui/themes/all.dart';

// A modified copy of: https://github.com/conghaonet/flutter_analog_clock
class ClockPainter extends CustomPainter {
  static const List<String> defaultHourNumbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];
  final DateTime _datetime;
  final Color dialPlateColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color numberColor;
  final Color borderColor;
  final Color centerPointColor;
  final double? centerPointRadius;
  final bool showBorder;
  final bool showMinuteHand;
  final bool showNumber;
  final double? hourHandLength;
  final double? minuteHandLength;
  final double? fontSize;
  final List<String> hourNumbers;
  final double? _borderWidth;
  final TextPainter _hourTextPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  ClockPainter(
    this._datetime, {
    this.dialPlateColor = Colors.transparent,
    this.hourHandColor = Colors.black,
    this.minuteHandColor = Colors.black,
    this.secondHandColor = Colors.black,
    this.numberColor = Colors.black,
    this.borderColor = Colors.black,
    this.centerPointColor = Colors.black,
    this.centerPointRadius,
    this.showBorder = true,
    this.showMinuteHand = true,
    this.showNumber = true,
    this.hourNumbers = defaultHourNumbers,
    this.fontSize,
    this.hourHandLength,
    this.minuteHandLength,
    double? borderWidth,
  }) : _borderWidth = borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2;
    final borderWidth = showBorder ? (_borderWidth ?? radius / 20.0) : 0.0;
    final circumference = 2 * (radius - borderWidth) * pi;
    final hourHandWidth = layout.clock.hourHandWidth;
    final minuteHandWidth = layout.clock.minuteHandWidth;

    canvas
      ..translate(size.width / 2, size.height / 2)
      ..drawCircle(
          const Offset(0, 0),
          radius,
          Paint()
            ..style = PaintingStyle.fill
            ..color = dialPlateColor);

    if (showBorder && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true;
      canvas.drawCircle(const Offset(0, 0), radius, borderPaint);
    }

    final bigTickWidth = circumference / 120;
    final tickRadius = (radius - borderWidth - bigTickWidth);

    final numberRadius = tickRadius - bigTickWidth * 3;
    var hourTextHeight = (radius - borderWidth) / 40 * 8;

    if (showNumber) {
      hourTextHeight = _paintHourText(canvas, numberRadius);
    }

    _paintHourHand(
        canvas, hourHandLength ?? numberRadius - hourTextHeight, hourHandWidth);

    if (showMinuteHand) {
      _paintMinuteHand(
          canvas,
          minuteHandLength ?? numberRadius - (hourTextHeight / 2),
          minuteHandWidth);
    }

    final centerPointPaint = Paint()
      ..strokeWidth = centerPointRadius ?? ((radius - borderWidth) / 10)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.src
      ..color = centerPointColor;
    canvas.drawPoints(PointMode.points, [const Offset(0, 0)], centerPointPaint);
  }

  double _paintHourText(Canvas canvas, double radius) {
    var maxTextHeight = 0.0;
    for (var i = 0; i < 12; i++) {
      final angle = i * 30.0;
      canvas.save();
      final hourNumberX = cos(getRadians(angle)) * radius;
      final hourNumberY = sin(getRadians(angle)) * radius;
      canvas.translate(hourNumberX, hourNumberY);
      var intHour = i + 3;
      if (intHour > 12) intHour = intHour - 12;
      final style = TextStyle(
        fontSize: fontSize ?? layout.clock.fontSize,
        fontWeight: medium,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
        color: numberColor,
      );
      final hourText = hourNumbers[intHour - 1];
      _hourTextPainter
        ..text = TextSpan(
          text: hourText,
          style: style,
        )
        ..layout();
      if (_hourTextPainter.height > maxTextHeight) {
        maxTextHeight = _hourTextPainter.height;
      }
      _hourTextPainter.paint(canvas,
          Offset(-_hourTextPainter.width / 2, -_hourTextPainter.height / 2));
      canvas.restore();
    }
    return maxTextHeight;
  }

  void _paintHourHand(Canvas canvas, double radius, double strokeWidth) {
    final angle = _datetime.hour % 12 + _datetime.minute / 60.0 - 3;
    final handOffset = Offset(cos(getRadians(angle * 30)) * radius,
        sin(getRadians(angle * 30)) * radius);
    final hourHandPaint = Paint()
      ..color = hourHandColor
      ..strokeWidth = strokeWidth;
    canvas.drawLine(const Offset(0, 0), handOffset, hourHandPaint);
  }

  void _paintMinuteHand(Canvas canvas, double radius, double strokeWidth) {
    final angle = _datetime.minute - 15.0;
    final handOffset = Offset(cos(getRadians(angle * 6.0)) * radius,
        sin(getRadians(angle * 6.0)) * radius);
    final hourHandPaint = Paint()
      ..color = minuteHandColor
      ..strokeWidth = strokeWidth;
    canvas.drawLine(const Offset(0, 0), handOffset, hourHandPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return _datetime != oldDelegate._datetime ||
        dialPlateColor != oldDelegate.dialPlateColor ||
        hourHandColor != oldDelegate.hourHandColor ||
        minuteHandColor != oldDelegate.minuteHandColor ||
        secondHandColor != oldDelegate.secondHandColor ||
        numberColor != oldDelegate.numberColor ||
        borderColor != oldDelegate.borderColor ||
        centerPointColor != oldDelegate.centerPointColor ||
        showBorder != oldDelegate.showBorder ||
        showMinuteHand != oldDelegate.showMinuteHand ||
        showNumber != oldDelegate.showNumber ||
        hourNumbers != oldDelegate.hourNumbers ||
        _borderWidth != oldDelegate._borderWidth ||
        fontSize != oldDelegate.fontSize;
  }

  static double getRadians(double angle) {
    return angle * pi / 180;
  }
}
