import 'dart:math';

import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/ui/components/timer/timer_wheel/timer_wheel_styles.dart';

class TimerWheelConfiguration {
  static const startAngle = -pi / 2;
  static const nrOfWheelSections = 12;
  static const minutesInEachSection = 5;

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

  // The width of the lines on the slider thumb in the design.
  static const _sliderThumbLineWidth = 1.0;

  // The length of the shorter lines on the slider thumb in the design.
  static const _shorterSliderThumbLineLength = 12.0;

  // The length of the longer lines on the slider thumb in the design.
  static const _longerSliderThumbLineLength = 16.0;

  TimerWheelConfiguration({
    required this.canvasSize,
    required this.style,
    required this.paused,
    required this.isPast,
  })  : assert(!(paused && style == TimerWheelStyle.interactive),
            'An interactive timer wheel cannot be paused'),
        assert(!(isPast && style == TimerWheelStyle.interactive),
            'An interactive timer wheel cannot be past');

  final Size canvasSize;
  final TimerWheelStyle style;
  final bool paused;
  final bool isPast;

  late final centerPoint = Offset(canvasSize.width / 2, canvasSize.height / 2);

  // The timer needs a square size to render properly, find the side of the largest possible square.
  late final shortestSide = min(canvasSize.width, canvasSize.height);
  late final scaleFactor = shortestSide /
      (style == TimerWheelStyle.simplified
          ? _simplifiedTimerWheelSides
          : _timerWheelSides);
  late final outerCircleDiameter = _outerWheelDiameter * scaleFactor;
  late final innerCircleDiameter = _innerWheelDiameter * scaleFactor;
  late final numberTextCircleDiameter = _numberCircleDiameter * scaleFactor;
  late final numberPointersCircleDiameter =
      _numberPointerCircleDiameter * scaleFactor;
  late final strokeWidth = _wheelStrokeWidth * scaleFactor;
  late final numberPointerWidth = _numberPointerWidth * scaleFactor;
  late final numberPointerLength = _numberPointerLengthInDesign * scaleFactor;
  late final numberPointerRoundedEdgeRadius = numberPointerWidth / 2;
  late final shortSliderThumbLineLength =
      _shorterSliderThumbLineLength * scaleFactor;
  late final longSliderThumbLineLength =
      _longerSliderThumbLineLength * scaleFactor;
  late final numberCircleDiameter = _numberCircleDiameter * scaleFactor;
  late final maxSize = _timerWheelSides * scaleFactor;

  late final wheelSectionsOutline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = AbiliaColors.white140;

  late final timeLeftFill = Paint()
    ..style = PaintingStyle.fill
    ..color = paused ? AbiliaColors.red40 : AbiliaColors.red100;

  late final timeLeftStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = paused ? AbiliaColors.red40 : AbiliaColors.red100;

  late final inactiveSectionFill = Paint()
    ..style = PaintingStyle.fill
    ..color = isPast ? AbiliaColors.white120 : AbiliaColors.white110;

  late final inactiveSectionStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..color = isPast ? AbiliaColors.white120 : AbiliaColors.white110;

  late final numberPointerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = numberPointerWidth
    ..color = AbiliaColors.white140;

  late final numberPointerRoundedEdgePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = AbiliaColors.white140;

  late final nowLinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = numberPointerWidth
    ..color = AbiliaColors.black
    ..strokeCap = StrokeCap.round;

  late final thumbRectanglePaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = numberPointerWidth
    ..color = AbiliaColors.black
    ..strokeCap = StrokeCap.round;

  late final thumbLinesPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _sliderThumbLineWidth * scaleFactor
    ..color = AbiliaColors.white140
    ..strokeCap = StrokeCap.round;

  late final numberTextStyle = bodyLarge.copyWith(
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
    fontSize: 16.0 * scaleFactor,
  );

  late final timeLeftTextStyle = titleLarge.copyWith(
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
    fontSize: 20.0 * scaleFactor,
  );
}
