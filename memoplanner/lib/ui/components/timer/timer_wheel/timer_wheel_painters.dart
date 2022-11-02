import 'dart:math';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/timer/timer_wheel/timer_wheel_styles.dart';
import 'package:seagull/ui/components/timer/timer_wheel/timer_wheel_config.dart';

class TimerWheelBackgroundPainter extends CustomPainter {
  TimerWheelBackgroundPainter({
    required this.config,
    required this.lengthInMinutes,
  }) : assert(!lengthInMinutes.isNegative) {
    _totalTimeSweepRadians = lengthInMinutes >= Duration.minutesPerHour
        ? 0
        : pi *
            2 *
            (Duration.minutesPerHour - lengthInMinutes) /
            Duration.minutesPerHour;
  }

  final TimerWheelConfiguration config;
  final int lengthInMinutes;
  late final double _totalTimeSweepRadians;

  @override
  void paint(Canvas canvas, Size size) {
    var wheelShape = _getWheelShape(
      Size(
        config.outerCircleDiameter,
        config.outerCircleDiameter,
      ),
      config.style,
    );
    wheelShape = wheelShape.shift(Offset(
      (size.width - config.outerCircleDiameter) / 2,
      (size.height - config.outerCircleDiameter) / 2,
    ));

    final inactiveSectionArc = Path()
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.outerCircleDiameter / 2,
        ),
        TimerWheelConfiguration.startAngle,
        _totalTimeSweepRadians,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.innerCircleDiameter / 2,
        ),
        TimerWheelConfiguration.startAngle + _totalTimeSweepRadians,
        -_totalTimeSweepRadians,
        false,
      )
      ..close();

    final inactiveTime = Path.combine(
      PathOperation.intersect,
      inactiveSectionArc,
      wheelShape,
    );

    canvas
      ..drawPath(wheelShape, config.wheelSectionsOutline)
      ..drawPath(inactiveTime, config.inactiveSectionFill)
      ..drawPath(inactiveTime, config.inactiveSectionStroke);

    // Paint section numbers
    if (config.style != TimerWheelStyle.simplified) {
      for (int i = 0; i < TimerWheelConfiguration.nrOfWheelSections; i++) {
        if (lengthInMinutes >=
            i * TimerWheelConfiguration.minutesInEachSection) {
          final numberPointerAngle =
              pi * 2 / TimerWheelConfiguration.nrOfWheelSections * i + pi;
          final innerRadius = config.numberPointersCircleDiameter / 2 -
              config.numberPointerLength;
          final outerRadius = config.numberPointersCircleDiameter / 2;

          final sinAngle = sin(numberPointerAngle);
          final cosAngle = cos(numberPointerAngle);

          final xShiftAmount = size.width / 2;
          final yShiftAmount = size.height / 2;

          // Paint number pointers
          final startX = innerRadius * sinAngle + xShiftAmount;
          final startY = innerRadius * cosAngle + yShiftAmount;
          final endX = outerRadius * sinAngle + xShiftAmount;
          final endY = outerRadius * cosAngle + yShiftAmount;

          final numberPointer = Path()
            ..moveTo(startX, startY)
            ..lineTo(endX, endY);

          final roundedEdge = Path()
            ..addOval(Rect.fromCircle(
              center: Offset(endX, endY),
              radius: config.numberPointerRoundedEdgeRadius,
            ));

          canvas
            ..drawPath(numberPointer, config.numberPointerPaint)
            ..drawPath(roundedEdge, config.numberPointerRoundedEdgePaint);

          // Paint numbers
          final numberTextCircleRadius = config.numberTextCircleDiameter / 2;

          final TextPainter numberTextPainter = TextPainter(
            text: TextSpan(
              text:
                  (i * TimerWheelConfiguration.minutesInEachSection).toString(),
              style: config.numberTextStyle,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout();

          final textX = numberTextCircleRadius * sinAngle +
              xShiftAmount -
              numberTextPainter.width / 2;
          final textY = numberTextCircleRadius * cosAngle +
              yShiftAmount -
              numberTextPainter.height / 2;

          numberTextPainter.paint(canvas, Offset(textX, textY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TimerWheelForegroundPainter extends CustomPainter {
  TimerWheelForegroundPainter({
    required this.config,
    required this.activeSeconds,
    required this.finished,
    required this.showTimeText,
  }) : assert(!activeSeconds.isNegative) {
    _timeLeftSweepRadians = activeSeconds >= Duration.secondsPerHour
        ? -pi * 2 + 0.001
        : -(pi * 2) * (activeSeconds / Duration.secondsPerHour);
  }

  final TimerWheelConfiguration config;
  final int activeSeconds;
  final bool finished;
  final bool showTimeText;
  late final double _timeLeftSweepRadians;

  @override
  void paint(Canvas canvas, Size size) {
    var wheelShape = _getWheelShape(
      Size(
        config.outerCircleDiameter,
        config.outerCircleDiameter,
      ),
      config.style,
    );
    wheelShape = wheelShape.shift(Offset(
      (size.width - config.outerCircleDiameter) / 2,
      (size.height - config.outerCircleDiameter) / 2,
    ));

    final timeLeftArc = Path()
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.outerCircleDiameter / 2,
        ),
        TimerWheelConfiguration.startAngle,
        _timeLeftSweepRadians,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.innerCircleDiameter / 2,
        ),
        TimerWheelConfiguration.startAngle + _timeLeftSweepRadians,
        -_timeLeftSweepRadians,
        false,
      )
      ..close();

    final timeLeft = Path.combine(
      PathOperation.intersect,
      timeLeftArc,
      wheelShape,
    );

    canvas.drawPath(timeLeft, config.timeLeftFill);
    canvas.drawPath(timeLeft, config.timeLeftStroke);

    // Paint time left as text and slider thumb
    if (config.style != TimerWheelStyle.simplified) {
      // Paint time left as text
      if (showTimeText) {
        final durationLeft =
            finished ? Duration.zero : Duration(seconds: activeSeconds);
        final timeLeftString =
            durationLeft.toString().split('.').first.padLeft(8, '0');

        final TextPainter timeLeftText = TextPainter(
          text: TextSpan(
            text: timeLeftString,
            style: config.timeLeftTextStyle,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        timeLeftText.paint(
          canvas,
          Offset(size.width / 2 - timeLeftText.width / 2,
              size.height / 2 - timeLeftText.height / 2),
        );
      }

      // Paint slider thumb
      if (config.style == TimerWheelStyle.interactive) {
        final sliderThumbAngle = -_timeLeftSweepRadians - pi;
        final innerRadius =
            config.innerCircleDiameter / 2 + config.strokeWidth / 2;
        final outerRadius = config.numberPointersCircleDiameter / 2;

        final sinAngle = sin(sliderThumbAngle);
        final cosAngle = cos(sliderThumbAngle);

        final xShiftAmount = size.width / 2;
        final yShiftAmount = size.height / 2;

        final startX = innerRadius * sinAngle + xShiftAmount;
        final startY = innerRadius * cosAngle + yShiftAmount;
        final endX = outerRadius * sinAngle + xShiftAmount;
        final endY = outerRadius * cosAngle + yShiftAmount;

        final nowLine = Path()
          ..moveTo(startX, startY)
          ..lineTo(endX, endY);

        var thumbRectangle = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(
                    config.centerPoint.dx,
                    config.centerPoint.dy -
                        (config.outerCircleDiameter / 4 +
                            config.innerCircleDiameter / 4),
                  ),
                  width: 24 * config.scaleFactor,
                  height: 32 * config.scaleFactor),
              Radius.circular(4.0 * config.scaleFactor),
            ),
          );

        thumbRectangle = thumbRectangle.transform(Matrix4Transform()
            .rotate(_timeLeftSweepRadians, origin: config.centerPoint)
            .matrix4
            .storage);

        final distanceBetweenInnerCircleToThumbLine = 21 * config.scaleFactor;
        final distanceBetweenLines = 3.0 * config.scaleFactor;

        var thumbLines = Path()
          ..moveTo(
            config.centerPoint.dx - distanceBetweenLines,
            config.centerPoint.dy -
                config.innerCircleDiameter / 2 -
                distanceBetweenInnerCircleToThumbLine,
          )
          ..relativeLineTo(0, -config.shortSliderThumbLineLength)
          ..relativeMoveTo(distanceBetweenLines * 2, 0)
          ..relativeLineTo(0, config.shortSliderThumbLineLength)
          ..relativeMoveTo(-distanceBetweenLines, 2 * config.scaleFactor)
          ..relativeLineTo(0, -config.longSliderThumbLineLength);

        thumbLines = thumbLines.transform(Matrix4Transform()
            .rotate(_timeLeftSweepRadians, origin: config.centerPoint)
            .matrix4
            .storage);

        canvas
          ..drawPath(nowLine, config.nowLinePaint)
          ..drawPath(thumbRectangle, config.thumbRectanglePaint)
          ..drawPath(thumbLines, config.thumbLinesPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimerWheelForegroundPainter oldDelegate) {
    return oldDelegate.activeSeconds != activeSeconds;
  }
}

Path _getWheelShape(Size size, TimerWheelStyle timerWheelStyle) {
  Path getLargeWheelShape(Size size) {
    //scaleFactor
    final sf = size.shortestSide / 212.0;

    final pointA = Offset(100.99 * sf, 0.75 * sf);
    final controlA1 = Offset(85.44 * sf, 1.48 * sf);
    final controlA2 = Offset(102.77 * sf, 0.67 * sf);

    final pointB = Offset(104.25 * sf, 3.93 * sf);
    final controlB1 = Offset(104.25 * sf, 2.12 * sf);

    final pointC = Offset(pointB.dx, 49.02 * sf);
    final controlC1 = Offset(pointC.dx, 50.78 * sf);

    final pointD = Offset(101.01 * sf, 52.54 * sf);
    final controlD1 = Offset(102.83 * sf, 52.25 * sf);
    final controlD2 = Offset(94.82 * sf, 52.99 * sf);

    final pointE = Offset(83.53 * sf, 57.09 * sf);
    final controlE1 = Offset(88.94 * sf, 54.61 * sf);
    final controlE2 = Offset(81.87 * sf, 57.86 * sf);

    final pointF = Offset(79.02 * sf, 55.77 * sf);
    final controlF1 = Offset(79.9 * sf, 57.29 * sf);

    final pointG = Offset(56.47 * sf, 16.71 * sf);
    final controlG1 = Offset(55.56 * sf, 15.14 * sf);

    final pointH = Offset(57.7 * sf, 12.33 * sf);
    final controlH1 = Offset(56.12 * sf, 13.15 * sf);
    final controlH2 = Offset(70.77 * sf, 5.58 * sf);

    final sectionShape = Path()
      ..moveTo(pointA.dx, pointA.dy)
      ..cubicTo(controlA2.dx, controlA2.dy, controlB1.dx, controlB1.dy,
          pointB.dx, pointB.dy)
      ..lineTo(pointC.dx, pointC.dy) // ok
      ..cubicTo(controlC1.dx, controlC1.dy, controlD1.dx, controlD1.dy,
          pointD.dx, pointD.dy)
      ..cubicTo(controlD2.dx, controlD2.dy, controlE1.dx, controlE1.dy,
          pointE.dx, pointE.dy)
      ..cubicTo(controlE2.dx, controlE2.dy, controlF1.dx, controlF1.dy,
          pointF.dx, pointF.dy)
      ..lineTo(pointG.dx, pointG.dy) // ok
      ..cubicTo(controlG1.dx, controlG1.dy, controlH1.dx, controlH1.dy,
          pointH.dx, pointH.dy)
      ..cubicTo(controlH2.dx, controlH2.dy, controlA1.dx, controlA1.dy,
          pointA.dx, pointA.dy)
      ..close();

    final timerWheelShape = Path();

    for (int i = 0; i < TimerWheelConfiguration.nrOfWheelSections; i++) {
      timerWheelShape.addPath(
          sectionShape.transform(Matrix4Transform()
              .rotate(
                (pi / 6) * i,
                origin: Offset(size.width / 2, size.height / 2),
              )
              .matrix4
              .storage),
          const Offset(0, 0));
    }

    return timerWheelShape;
  }

  Path getSmallWheelShape(Size size) {
    //scaleFactor
    final sf = size.shortestSide / 43.9;

    final pointA = Offset(20.45 * sf, 0.25 * sf);
    final controlA1 = Offset(17.58 * sf, 0.45 * sf);
    final controlA2 = Offset(20.85 * sf, 0.22 * sf);

    final pointB = Offset(21.2 * sf, 0.98 * sf);
    final controlB1 = Offset(21.2 * sf, 0.55 * sf);

    final pointC = Offset(pointB.dx, 10.01 * sf);
    final controlC1 = Offset(pointC.dx, 10.4 * sf);

    final pointD = Offset(20.47 * sf, 10.8 * sf);
    final controlD1 = Offset(20.88 * sf, 10.74 * sf);
    final controlD2 = Offset(19.48 * sf, 10.93 * sf);

    final pointE = Offset(17.66 * sf, 11.55 * sf);
    final controlE1 = Offset(18.54 * sf, 11.18 * sf);
    final controlE2 = Offset(17.27 * sf, 11.71 * sf);

    final pointF = Offset(16.63 * sf, 11.23 * sf);
    final controlF1 = Offset(16.82 * sf, 11.57 * sf);

    final pointG = Offset(12.11 * sf, 3.41 * sf);
    final controlG1 = Offset(11.9 * sf, 3.04 * sf);

    final pointH = Offset(12.4 * sf, 2.4 * sf);
    final controlH1 = Offset(12.03 * sf, 2.58 * sf);
    final controlH2 = Offset(14.86 * sf, 1.2 * sf);

    final sectionShape = Path()
      ..moveTo(pointA.dx, pointA.dy)
      ..cubicTo(controlA2.dx, controlA2.dy, controlB1.dx, controlB1.dy,
          pointB.dx, pointB.dy)
      ..lineTo(pointC.dx, pointC.dy) // ok
      ..cubicTo(controlC1.dx, controlC1.dy, controlD1.dx, controlD1.dy,
          pointD.dx, pointD.dy)
      ..cubicTo(controlD2.dx, controlD2.dy, controlE1.dx, controlE1.dy,
          pointE.dx, pointE.dy)
      ..cubicTo(controlE2.dx, controlE2.dy, controlF1.dx, controlF1.dy,
          pointF.dx, pointF.dy)
      ..lineTo(pointG.dx, pointG.dy) // ok
      ..cubicTo(controlG1.dx, controlG1.dy, controlH1.dx, controlH1.dy,
          pointH.dx, pointH.dy)
      ..cubicTo(controlH2.dx, controlH2.dy, controlA1.dx, controlA1.dy,
          pointA.dx, pointA.dy)
      ..close();

    final timerWheelShape = Path();

    for (int i = 0; i < TimerWheelConfiguration.nrOfWheelSections; i++) {
      timerWheelShape.addPath(
          sectionShape.transform(Matrix4Transform()
              .rotate(
                (pi / 6) * i,
                origin: Offset(size.width / 2, size.height / 2),
              )
              .matrix4
              .storage),
          const Offset(0, 0));
    }

    return timerWheelShape;
  }

  if (timerWheelStyle == TimerWheelStyle.simplified) {
    return getSmallWheelShape(size);
  } else {
    return getLargeWheelShape(size);
  }
}
