import 'dart:math';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/timer_wheel/constants.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_config.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_shape.dart';

class TimerWheelBackgroundPainter extends CustomPainter {
  static const _startAngle = -pi / 2;
  static const _nrOfWheelSections = 12;
  static const _minutesInEachSection = 5;

  TimerWheelBackgroundPainter({
    required this.config,
    required this.timerLengthInMinutes,
  }) : assert(!timerLengthInMinutes.isNegative,
            'timerLengthInMinutes cannot be negative') {
    _totalTimeSweepRadians = timerLengthInMinutes >= minutesInOneHour
        ? 0
        : (pi * 2) *
            ((minutesInOneHour - timerLengthInMinutes) / minutesInOneHour);
  }

  final TimerWheelConfiguration config;
  final int timerLengthInMinutes;
  late final double _totalTimeSweepRadians;

  @override
  void paint(Canvas canvas, Size size) {
    var wheelShape = getWheelShape(Size(
      config.outerCircleDiameter,
      config.outerCircleDiameter,
    ));
    wheelShape = wheelShape.shift(Offset(
      (size.width - config.outerCircleDiameter) / 2,
      (size.height - config.outerCircleDiameter) / 2,
    ));

    Path inactiveSectionArc = Path()
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.outerCircleDiameter / 2,
        ),
        _startAngle,
        _totalTimeSweepRadians,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.innerCircleDiameter / 2,
        ),
        _startAngle + _totalTimeSweepRadians,
        -_totalTimeSweepRadians,
        false,
      )
      ..close();

    Path inactiveTime = Path.combine(
      PathOperation.intersect,
      inactiveSectionArc,
      wheelShape,
    );

    canvas.drawPath(wheelShape, config.wheelSectionsOutline);
    canvas.drawPath(inactiveTime, config.inactiveSectionFill);
    canvas.drawPath(inactiveTime, config.inactiveSectionStroke);

    // If timer is not simplified, also paint section numbers and time left as text
    if (config.style != TimerWheelStyle.simplified) {
      for (int i = 0; i < _nrOfWheelSections; i++) {
        if (timerLengthInMinutes >= (i * _minutesInEachSection)) {
          final numberPointerAngle = (pi * 2 / _nrOfWheelSections) * i + pi;
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

          var roundedEdge = Path()
            ..addOval(Rect.fromCircle(
              center: Offset(endX, endY),
              radius: config.numberPointerRoundedEdgeRadius,
            ));

          canvas.drawPath(numberPointer, config.numberPointerPaint);
          canvas.drawPath(roundedEdge, config.numberPointerRoundedEdgePaint);

          // Paint numbers
          final numberTextCircleRadius = config.numberTextCircleDiameter / 2;

          final TextPainter numberTextPainter = TextPainter(
            text: TextSpan(
              text: (i * _minutesInEachSection).toString(),
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
  static const _startAngle = -pi / 2;

  TimerWheelForegroundPainter({
    required this.config,
    required this.secondsLeft,
  }) : assert(!secondsLeft.isNegative, 'secondsLeft cannot be negative') {
    _timeLeftSweepRadians = secondsLeft >= secondsInOneHour
        ? -pi * 2 + 0.001
        : -(pi * 2) * (secondsLeft / secondsInOneHour);
  }

  final TimerWheelConfiguration config;
  final int secondsLeft;
  late final double _timeLeftSweepRadians;

  @override
  void paint(Canvas canvas, Size size) {
    var wheelShape = getWheelShape(Size(
      config.outerCircleDiameter,
      config.outerCircleDiameter,
    ));
    wheelShape = wheelShape.shift(Offset(
      (size.width - config.outerCircleDiameter) / 2,
      (size.height - config.outerCircleDiameter) / 2,
    ));

    Path timeLeftArc = Path()
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.outerCircleDiameter / 2,
        ),
        _startAngle,
        _timeLeftSweepRadians,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: config.centerPoint,
          radius: config.innerCircleDiameter / 2,
        ),
        _startAngle + _timeLeftSweepRadians,
        -_timeLeftSweepRadians,
        false,
      )
      ..close();

    Path timeLeft = Path.combine(
      PathOperation.intersect,
      timeLeftArc,
      wheelShape,
    );

    canvas.drawPath(timeLeft, config.timeLeftFill);
    canvas.drawPath(timeLeft, config.timeLeftStroke);

    // If timer is not simplified, paint section numbers and time left as text
    if (config.style != TimerWheelStyle.simplified) {
      // Paint time left as text
      final durationLeft = Duration(seconds: secondsLeft);
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

      // If timer is interactive, paint slider thumb
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

        canvas.drawPath(nowLine, config.nowLinePaint);
        canvas.drawPath(thumbRectangle, config.thumbRectanglePaint);
        canvas.drawPath(thumbLines, config.thumbLinesPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimerWheelForegroundPainter oldDelegate) {
    return oldDelegate.secondsLeft != secondsLeft;
  }
}
