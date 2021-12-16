import 'dart:math';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/timer_wheel/timer_wheel_shape.dart';

const _secondsInOneMinute = 60;
const _minutesInOneHour = 60;
const _secondsInOneHour = _minutesInOneHour * _secondsInOneMinute;

enum TimerWheelStyle {
  simplified,
  interactive,
  nonInteractive,
}

class TimerWheel extends StatefulWidget {
  const TimerWheel({
    Key? key,
    required this.style,
    this.timerLengthInMinutes,
    this.secondsLeft,
  })  : assert(
            !(style == TimerWheelStyle.interactive &&
                (timerLengthInMinutes != null || secondsLeft != null)),
            'When style is TimerWheelStyle.interactive, timerLengthInMinutes and secondsLeft will be ignored and should be null'),
        super(key: key);

  final TimerWheelStyle style;
  final int? timerLengthInMinutes;
  final int? secondsLeft;

  @override
  _TimerWheelState createState() => _TimerWheelState();
}

class _TimerWheelState extends State<TimerWheel> {
  //Range [0..1]
  late double sliderValue = _sliderValueFromSeconds(widget.secondsLeft ?? 0);
  int get minutesSelected => _minutesFromSliderValue(sliderValue);
  int? minutesSelectedOnTapDown;
  bool sliderTemporaryLocked = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final config = TimerWheelConfiguration(
        canvasSize: constraints.biggest,
        simplified: widget.style == TimerWheelStyle.simplified,
      );

      final Widget timerWheel = CustomPaint(
        size: constraints.biggest,
        painter: TimerWheelPainter(
          config: config,
          simplified: widget.style == TimerWheelStyle.simplified,
          timerLengthInMinutes:
              widget.timerLengthInMinutes ?? _minutesInOneHour,
          secondsLeft: widget.style == TimerWheelStyle.interactive
              ? minutesSelected * _secondsInOneMinute
              : widget.secondsLeft ?? 0,
        ),
      );

      if (widget.style != TimerWheelStyle.interactive) {
        return timerWheel;
      } else {
        return GestureDetector(
          onPanDown: (details) => _onPanDown(details, config),
          onPanUpdate: (details) => _onPanUpdate(details, config),
          onTapUp: _onTapUp,
          child: timerWheel,
        );
      }
    });
  }

  _onPanDown(DragDownDetails details, TimerWheelConfiguration config) {
    sliderTemporaryLocked = false;
    if (_pointIsOnWheel(details.localPosition, config)) {
      sliderValue = _sliderValueFromPoint(details.localPosition, config);
      minutesSelectedOnTapDown = minutesSelected;
    }
  }

  _onPanUpdate(DragUpdateDetails details, TimerWheelConfiguration config) {
    void maybeLockSlider(double value) {
      const margin = 5;

      final isCrossingZeroForwards =
          minutesSelected > _minutesInOneHour - margin &&
              _minutesFromSliderValue(value) < margin;
      final isCrossingZeroBackwards = minutesSelected < margin &&
          _minutesFromSliderValue(value) > _minutesInOneHour - margin;

      if (isCrossingZeroForwards || isCrossingZeroBackwards) {
        setState(() {
          sliderTemporaryLocked = true;
          sliderValue = isCrossingZeroBackwards ? 0 : 1;
        });
        return;
      }

      if (minutesSelected >= _minutesInOneHour - margin &&
              _minutesFromSliderValue(value) >= _minutesInOneHour - margin ||
          minutesSelected <= margin &&
              _minutesFromSliderValue(value) <= margin) {
        sliderTemporaryLocked = false;
      }
    }

    if (_pointIsOnWheel(details.localPosition, config)) {
      final sliderValue = _sliderValueFromPoint(details.localPosition, config);

      maybeLockSlider(sliderValue);

      if (sliderTemporaryLocked) {
        return;
      }

      setState(() {
        this.sliderValue = sliderValue;
      });
    }
  }

  _onTapUp(TapUpDetails details) {
    if (minutesSelectedOnTapDown == minutesSelected) {
      int desiredMinutesLeft =
          ((sliderValue * _minutesInOneHour) / 5).ceil() * 5;
      assert(desiredMinutesLeft >= 0 && desiredMinutesLeft <= _minutesInOneHour,
          'Tried setting timer wheel to invalid time');
      desiredMinutesLeft.clamp(0, _minutesInOneHour);
      setState(() {
        sliderValue = desiredMinutesLeft / _minutesInOneHour;
      });
    }
    minutesSelectedOnTapDown = null;
  }

  bool _pointIsOnWheel(Offset point, TimerWheelConfiguration config) {
    final distanceFromCenter = sqrt(
      pow((point.dx - config.centerPoint.dx), 2) +
          pow((point.dy - config.centerPoint.dy), 2),
    );

    return distanceFromCenter <= config.outerCircleDiameter / 2 &&
        distanceFromCenter >= config.innerCircleDiameter / 2;
  }

  // Returns a value in range: [0..60]
  int _minutesFromSliderValue(double value) {
    assert(value >= 0 && value <= 1, 'Given value is out of range [0..1]');
    value.clamp(0, 1);
    return (value * _minutesInOneHour).floor();
  }

  // Returns a value in range: [0..1]
  double _sliderValueFromPoint(Offset point, TimerWheelConfiguration config) {
    final deltaX = point.dx - config.centerPoint.dx;
    final deltaY = config.centerPoint.dy - point.dy;
    var angle = atan2(deltaY, deltaX);
    angle = angle - pi / 2;

    if (angle.isNegative) {
      angle = angle + 2 * pi;
    }

    return angle / (2 * pi);
  }

  // Returns a value in range: [0..1]
  double _sliderValueFromSeconds(int seconds) {
    return seconds.clamp(0, _secondsInOneHour) / _secondsInOneHour;
  }
}

class TimerWheelConfiguration {
  // The side of the smallest possible square that contains the full timer in the design
  static const _timerWheelSides = 292.0;
  // The side of the smallest possible square that contains the simplified timer in the design
  static const _simplifiedTimerWheelSides = _outerWheelDiameter;
  // The diameter of the circle on which the numbers are placed in the design
  static const _numberCircleDiameter = 268.0;
  // The diameter of the circle on which the number pointers are placed in the design
  static const _numberPointerCircleDiameter = 236.0;
  // The diameter of the outer circle of the wheel in the design
  static const _outerWheelDiameter = 212.0;
  // The diameter of the inner circle of the wheel in the design
  static const _innerWheelDiameter = 106.0;
  // The stroke width of the wheel in the design
  static const _wheelStrokeWidth = 1.5;
  // The width of the number pointers in the design
  static const _numberPointerWidth = 2.0;
  // The length of the number pointers in the design
  static const _numberPointerLengthInDesign = 8.0;
  //The font size of the numbers in the design. Only used as fallback if bodyText1 has no FontSize
  static const _fallbackNumberFontSize = 16.0;

  TimerWheelConfiguration({
    required this.canvasSize,
    required this.simplified,
  });

  final Size canvasSize;
  final bool simplified;

  late final centerPoint = Offset(canvasSize.width / 2, canvasSize.height / 2);
  // The timer needs a square size to render properly, find the side of the largest possible square.
  late final shortestSide = min(canvasSize.width, canvasSize.height);
  late final scaleFactor = shortestSide /
      (simplified ? _simplifiedTimerWheelSides : _timerWheelSides);
  late final outerCircleDiameter = _outerWheelDiameter * scaleFactor;
  late final innerCircleDiameter = _innerWheelDiameter * scaleFactor;
  late final numberTextCircleDiameter = _numberCircleDiameter * scaleFactor;
  late final numberPointersCircleDiameter =
      _numberPointerCircleDiameter * scaleFactor;
  late final strokeWidth = _wheelStrokeWidth * scaleFactor;
  late final numberPointerWidth = _numberPointerWidth * scaleFactor;
  late final numberPointerLength = _numberPointerLengthInDesign * scaleFactor;
  late final numberPointerRoundedEdgeRadius = numberPointerWidth / 2;

  late final wheelSectionsOutline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = AbiliaColors.white140;

  late final timeLeftFill = Paint()
    ..style = PaintingStyle.fill
    ..color = AbiliaColors.red100;

  late final timeLeftStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = AbiliaColors.red100;

  late final inactiveSectionFill = Paint()
    ..style = PaintingStyle.fill
    ..color = AbiliaColors.white110;

  late final inactiveSectionStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = AbiliaColors.white110;

  late final numberPointerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = numberPointerWidth
    ..color = AbiliaColors.white140;

  late final numberPointerRoundedEdgePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = AbiliaColors.white140;

  late final numberTextStyle = bodyText1.copyWith(
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
      fontSize: (bodyText1.fontSize ?? _fallbackNumberFontSize) *
          (shortestSide / _timerWheelSides));

  late final timeLeftTextStyle = headline6.copyWith(
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
      fontSize: (headline6.fontSize ?? headline6FontSize) *
          (shortestSide / _timerWheelSides));
}

class TimerWheelPainter extends CustomPainter {
  static const _startAngle = -pi / 2;
  static const _nrOfWheelSections = 12;
  static const _minutesInEachSection = 5;

  TimerWheelPainter({
    required this.config,
    required this.simplified,
    required this.secondsLeft,
    required this.timerLengthInMinutes,
  })  : assert(
            secondsLeft >= 0 &&
                secondsLeft <= timerLengthInMinutes * _secondsInOneMinute,
            'secondsLeft is not in range'),
        assert(timerLengthInMinutes >= 0,
            'timerLengthInMinutes has to be non-negative') {
    _timeLeftSweepRadians = secondsLeft >= _secondsInOneHour
        ? -pi * 2 +
            0.001 // If we want to fill the circle, we can't use 2 pi because that is the same as 0 sweep. Adding a very small number solves this.
        : -(pi * 2) * (secondsLeft / _secondsInOneHour);

    _totalTimeSweepRadians = timerLengthInMinutes >= _minutesInOneHour
        ? 0
        : (pi * 2) *
            ((_minutesInOneHour - timerLengthInMinutes) / _minutesInOneHour);
  }

  final TimerWheelConfiguration config;
  final bool simplified;
  final int secondsLeft;
  final int timerLengthInMinutes;
  late final double _timeLeftSweepRadians;
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

    Path timeLeft = Path.combine(
      PathOperation.intersect,
      timeLeftArc,
      wheelShape,
    );

    Path inactiveTime = Path.combine(
      PathOperation.intersect,
      inactiveSectionArc,
      wheelShape,
    );

    canvas.drawPath(wheelShape, config.wheelSectionsOutline);
    canvas.drawPath(timeLeft, config.timeLeftFill);
    canvas.drawPath(timeLeft, config.timeLeftStroke);
    canvas.drawPath(inactiveTime, config.inactiveSectionFill);
    canvas.drawPath(inactiveTime, config.inactiveSectionStroke);

    // If timer is simplified, also paint section numbers and time left as text
    if (!simplified) {
      for (int i = 0; i < _nrOfWheelSections; i++) {
        if (timerLengthInMinutes >= (i * _minutesInEachSection)) {
          final numberPointerAngle = (pi * 2 / _nrOfWheelSections) * i + pi;
          final innerRadius = config.numberPointersCircleDiameter / 2 -
              config.numberPointerLength;
          final outerRadius = config.numberPointersCircleDiameter / 2 -
              config.numberPointerRoundedEdgeRadius;

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
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
