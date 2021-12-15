import 'dart:math';
import 'package:seagull/ui/all.dart';

const _minutesInOneHour = 60;
const _secondsInOneHour = _minutesInOneHour * _minutesInOneHour;
const _startAngle = -pi / 2;
const _nrOfWheelSections = 12;
const _minutesInEachSection = 5;
// The side of the smallest possible square that contains the full timer in the design
const _timerWheelSides = 292.0;
// The side of the smallest possible square that contains the simplified timer in the design
const _simplifiedTimerWheelSides = _outerWheelDiameter;
// The diameter of the circle on which the numbers are placed in the design
const _numberCircleDiameter = 268.0;
// The diameter of the circle on which the number pointers are placed in the design
const _numberPointerCircleDiameter = 236.0;
// The diameter of the outer circle of the wheel in the design
const _outerWheelDiameter = 212.0;
// The diameter of the inner circle of the wheel in the design
const _innerWheelDiameter = 106.0;
// The stroke width of the wheel in the design
const _wheelStrokeWidth = 1.5;
// The width of the number pointers in the design
const _numberPointerWidth = 2.0;
// The length of the number pointers in the design
const _numberPointerLengthInDesign = 8.0;
//The font size of the numbers in the design.
// Only used as fallback if [bodyText1] has no [FontSize]
const _fallbackNumberFontSize = 16.0;

class TimerWheelPainter extends CustomPainter {
  TimerWheelPainter({
    this.simplified = false,
    required this.secondsLeft,
    required this.timerLengthInMinutes,
  })  : assert(secondsLeft >= 0 && secondsLeft <= timerLengthInMinutes * 60,
            'secondsLeft is not in range'),
        assert(timerLengthInMinutes >= 0,
            'timerLengthInMinutes has to be non-negative') {
    _timeLeftSweepRadians = secondsLeft >= _secondsInOneHour
        ? -pi * 2 +
            0.001 // If we want to fill the circle, we can't use 2 pi because that is the same as 0 sweep. Adding a very small number solves this.
        : -(pi * 2) * (secondsLeft / _secondsInOneHour);

    _totalTimeSweepRadians = timerLengthInMinutes >= 60
        ? 0
        : (pi * 2) *
            ((_minutesInOneHour - timerLengthInMinutes) / _minutesInOneHour);
  }

  final bool simplified;
  final int secondsLeft;
  final int timerLengthInMinutes;
  late final double _timeLeftSweepRadians;
  late final double _totalTimeSweepRadians;

  @override
  void paint(Canvas canvas, Size size) {
    final centerPoint = Offset(size.width / 2, size.height / 2);

    // The timer needs a square size to render properly,
    // find the side of the largest possible square.
    final shortestSide = min(size.width, size.height);

    final scaleFactor = shortestSide /
        (simplified ? _simplifiedTimerWheelSides : _timerWheelSides);

    // Scaled sizes
    final outerCircleDiameter = _outerWheelDiameter * scaleFactor;
    final innerCircleDiameter = _innerWheelDiameter * scaleFactor;
    final numberTextCircleDiameter = _numberCircleDiameter * scaleFactor;
    final numberPointersCircleDiameter =
        _numberPointerCircleDiameter * scaleFactor;
    final strokeWidth = _wheelStrokeWidth * scaleFactor;

    // Paints
    Paint wheelSectionsOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AbiliaColors.white140;

    Paint timeLeftFill = Paint()
      ..style = PaintingStyle.fill
      ..color = AbiliaColors.red100;

    Paint timeLeftStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AbiliaColors.red100;

    Paint inactiveSectionFill = Paint()
      ..style = PaintingStyle.fill
      ..color = AbiliaColors.white110;

    Paint inactiveSectionStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AbiliaColors.white110;

    // Paths
    var wheelShape = _wheelShape(Size(
      outerCircleDiameter,
      outerCircleDiameter,
    ));
    wheelShape = wheelShape.shift(Offset(
      (size.width - outerCircleDiameter) / 2,
      (size.height - outerCircleDiameter) / 2,
    ));

    Path timeLeftArc = Path()
      ..arcTo(
        Rect.fromCircle(
          center: centerPoint,
          radius: outerCircleDiameter / 2,
        ),
        _startAngle,
        _timeLeftSweepRadians,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: centerPoint,
          radius: innerCircleDiameter / 2,
        ),
        _startAngle + _timeLeftSweepRadians,
        -_timeLeftSweepRadians,
        false,
      )
      ..close();

    Path inactiveSectionArc = Path()
      ..arcTo(
        Rect.fromCircle(
          center: centerPoint,
          radius: outerCircleDiameter / 2,
        ),
        _startAngle,
        _totalTimeSweepRadians,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: centerPoint,
          radius: innerCircleDiameter / 2,
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

    canvas.drawPath(wheelShape, wheelSectionsOutline);
    canvas.drawPath(timeLeft, timeLeftFill);
    canvas.drawPath(timeLeft, timeLeftStroke);
    canvas.drawPath(inactiveTime, inactiveSectionFill);
    canvas.drawPath(inactiveTime, inactiveSectionStroke);

    // If timer is simplified, also paint section numbers and time left as text
    if (!simplified) {
      // Scaled sizes
      final numberPointerWidth = _numberPointerWidth * scaleFactor;
      final numberPointerLength = _numberPointerLengthInDesign * scaleFactor;
      final numberPointerRoundedEdgeRadius = numberPointerWidth / 2;

      // Paints
      Paint numberPointerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = numberPointerWidth
        ..color = AbiliaColors.white140;

      Paint numberPointerRoundedEdgePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = AbiliaColors.white140;

      // TextStyles
      assert(bodyText1.fontSize != null,
          'If fontSize is null, we cannot set it correctly in the timer wheel');
      final TextStyle numberTextStyle = bodyText1.copyWith(
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
          fontSize: (bodyText1.fontSize ?? _fallbackNumberFontSize) *
              (shortestSide / _timerWheelSides));

      assert(headline6.fontSize != null,
          'If fontSize is null, we cannot set it correctly in the timer wheel');
      final TextStyle timeLeftTextStyle = headline6.copyWith(
          height: 1,
          leadingDistribution: TextLeadingDistribution.even,
          fontSize: (headline6.fontSize ?? headline6FontSize) *
              (shortestSide / _timerWheelSides));

      for (int i = 0; i < _nrOfWheelSections; i++) {
        if (timerLengthInMinutes >= (i * _minutesInEachSection)) {
          final numberPointerAngle = (pi * 2 / _nrOfWheelSections) * i + pi;
          final innerRadius =
              numberPointersCircleDiameter / 2 - numberPointerLength;
          final outerRadius =
              numberPointersCircleDiameter / 2 - numberPointerRoundedEdgeRadius;

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
              radius: numberPointerRoundedEdgeRadius,
            ));

          canvas.drawPath(numberPointer, numberPointerPaint);
          canvas.drawPath(roundedEdge, numberPointerRoundedEdgePaint);

          // Paint numbers
          final numberTextCircleRadius = numberTextCircleDiameter / 2;

          final TextPainter numberTextPainter = TextPainter(
            text: TextSpan(
              text: (i * _minutesInEachSection).toString(),
              style: numberTextStyle,
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
      final TextPainter timeLeftText = TextPainter(
        text: TextSpan(
          text: _secondsToTimeLeft(secondsLeft),
          style: timeLeftTextStyle,
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

String _secondsToTimeLeft(int value) {
  final duration = Duration(seconds: value);
  return duration.toString().split('.').first.padLeft(8, '0');
}

/// TODO: Replace this method with a code gen package from pub.dev and have the SVG file in repo?
/// This code was generated using the "SVG to Custom Paint" tool at
/// https://fluttershapemaker.com/
Path _wheelShape(Size size) {
  Path path_0 = Path();
  path_0.moveTo(size.width * 0.2718802, size.height * 0.05812311);
  path_0.cubicTo(
      size.width * 0.3334807,
      size.height * 0.02629325,
      size.width * 0.4025991,
      size.height * 0.006981368,
      size.width * 0.4758774,
      size.height * 0.003554024);
  path_0.cubicTo(
      size.width * 0.4842500,
      size.height * 0.003162368,
      size.width * 0.4912123,
      size.height * 0.009972642,
      size.width * 0.4912123,
      size.height * 0.01853071);
  path_0.lineTo(size.width * 0.4912123, size.height * 0.2309873);
  path_0.cubicTo(
      size.width * 0.4912123,
      size.height * 0.2392830,
      size.width * 0.4845189,
      size.height * 0.2462156,
      size.width * 0.4759340,
      size.height * 0.2470061);
  path_0.cubicTo(
      size.width * 0.4467835,
      size.height * 0.2496892,
      size.width * 0.4190590,
      size.height * 0.2573075,
      size.width * 0.3936066,
      size.height * 0.2690184);
  path_0.cubicTo(
      size.width * 0.3857689,
      size.height * 0.2726250,
      size.width * 0.3765009,
      size.height * 0.2699665,
      size.width * 0.3723519,
      size.height * 0.2627797);
  path_0.lineTo(size.width * 0.2661005, size.height * 0.07874670);
  path_0.cubicTo(
      size.width * 0.2618226,
      size.height * 0.07133774,
      size.width * 0.2644396,
      size.height * 0.06196792,
      size.width * 0.2718802,
      size.height * 0.05812311);
  path_0.close();
  path_0.moveTo(size.width * 0.5077217, size.height * 0.2309873);
  path_0.lineTo(size.width * 0.5077217, size.height * 0.01853071);
  path_0.cubicTo(
      size.width * 0.5077217,
      size.height * 0.009972642,
      size.width * 0.5146840,
      size.height * 0.003162368,
      size.width * 0.5230566,
      size.height * 0.003554024);
  path_0.cubicTo(
      size.width * 0.5963349,
      size.height * 0.006981462,
      size.width * 0.6654575,
      size.height * 0.02629453,
      size.width * 0.7270566,
      size.height * 0.05812642);
  path_0.cubicTo(
      size.width * 0.7345000,
      size.height * 0.06197123,
      size.width * 0.7371132,
      size.height * 0.07134104,
      size.width * 0.7328349,
      size.height * 0.07875000);
  path_0.lineTo(size.width * 0.6265849, size.height * 0.2627825);
  path_0.cubicTo(
      size.width * 0.6224387,
      size.height * 0.2699693,
      size.width * 0.6131698,
      size.height * 0.2726278,
      size.width * 0.6053302,
      size.height * 0.2690212);
  path_0.cubicTo(
      size.width * 0.5798774,
      size.height * 0.2573090,
      size.width * 0.5521509,
      size.height * 0.2496896,
      size.width * 0.5230000,
      size.height * 0.2470061);
  path_0.cubicTo(
      size.width * 0.5144151,
      size.height * 0.2462156,
      size.width * 0.5077217,
      size.height * 0.2392830,
      size.width * 0.5077217,
      size.height * 0.2309873);
  path_0.close();
  path_0.moveTo(size.width * 0.7063491, size.height * 0.3528679);
  path_0.cubicTo(
      size.width * 0.6897925,
      size.height * 0.3295429,
      size.width * 0.6693868,
      size.height * 0.3091396,
      size.width * 0.6460613,
      size.height * 0.2925816);
  path_0.cubicTo(
      size.width * 0.6390377,
      size.height * 0.2875953,
      size.width * 0.6367170,
      size.height * 0.2782528,
      size.width * 0.6408632,
      size.height * 0.2710750);
  path_0.lineTo(size.width * 0.7471132, size.height * 0.08704340);
  path_0.cubicTo(
      size.width * 0.7513962,
      size.height * 0.07962500,
      size.width * 0.7608349,
      size.height * 0.07721179,
      size.width * 0.7678868,
      size.height * 0.08175236);
  path_0.cubicTo(
      size.width * 0.8276840,
      size.height * 0.1202561,
      size.width * 0.8786745,
      size.height * 0.1712481,
      size.width * 0.9171792,
      size.height * 0.2310420);
  path_0.cubicTo(
      size.width * 0.9217170,
      size.height * 0.2380929,
      size.width * 0.9193066,
      size.height * 0.2475344,
      size.width * 0.9118868,
      size.height * 0.2518179);
  path_0.lineTo(size.width * 0.7278538, size.height * 0.3580684);
  path_0.cubicTo(
      size.width * 0.7206792,
      size.height * 0.3622127,
      size.width * 0.7113349,
      size.height * 0.3598929,
      size.width * 0.7063491,
      size.height * 0.3528679);
  path_0.close();
  path_0.moveTo(size.width * 0.7361462, size.height * 0.3723443);
  path_0.lineTo(size.width * 0.9201792, size.height * 0.2660929);
  path_0.cubicTo(
      size.width * 0.9275896,
      size.height * 0.2618151,
      size.width * 0.9369575,
      size.height * 0.2644325,
      size.width * 0.9408066,
      size.height * 0.2718726);
  path_0.cubicTo(
      size.width * 0.9726368,
      size.height * 0.3334750,
      size.width * 0.9919481,
      size.height * 0.4025958,
      size.width * 0.9953774,
      size.height * 0.4758774);
  path_0.cubicTo(
      size.width * 0.9957689,
      size.height * 0.4842500,
      size.width * 0.9889575,
      size.height * 0.4912123,
      size.width * 0.9804009,
      size.height * 0.4912123);
  path_0.lineTo(size.width * 0.7679434, size.height * 0.4912123);
  path_0.cubicTo(
      size.width * 0.7596462,
      size.height * 0.4912123,
      size.width * 0.7527170,
      size.height * 0.4845189,
      size.width * 0.7519245,
      size.height * 0.4759340);
  path_0.cubicTo(
      size.width * 0.7492406,
      size.height * 0.4467807,
      size.width * 0.7416226,
      size.height * 0.4190538,
      size.width * 0.7299104,
      size.height * 0.3935995);
  path_0.cubicTo(
      size.width * 0.7263019,
      size.height * 0.3857618,
      size.width * 0.7289623,
      size.height * 0.3764939,
      size.width * 0.7361462,
      size.height * 0.3723443);
  path_0.close();
  path_0.moveTo(size.width * 0.7679434, size.height * 0.5077217);
  path_0.lineTo(size.width * 0.9804009, size.height * 0.5077217);
  path_0.cubicTo(
      size.width * 0.9889575,
      size.height * 0.5077217,
      size.width * 0.9957689,
      size.height * 0.5146840,
      size.width * 0.9953774,
      size.height * 0.5230566);
  path_0.cubicTo(
      size.width * 0.9919481,
      size.height * 0.5963349,
      size.width * 0.9726368,
      size.height * 0.6654528,
      size.width * 0.9408066,
      size.height * 0.7270566);
  path_0.cubicTo(
      size.width * 0.9369623,
      size.height * 0.7344953,
      size.width * 0.9275896,
      size.height * 0.7371132,
      size.width * 0.9201840,
      size.height * 0.7328349);
  path_0.lineTo(size.width * 0.7361509, size.height * 0.6265849);
  path_0.cubicTo(
      size.width * 0.7289623,
      size.height * 0.6224340,
      size.width * 0.7263066,
      size.height * 0.6131651,
      size.width * 0.7299104,
      size.height * 0.6053302);
  path_0.cubicTo(
      size.width * 0.7416226,
      size.height * 0.5798774,
      size.width * 0.7492406,
      size.height * 0.5521509,
      size.width * 0.7519245,
      size.height * 0.5230000);
  path_0.cubicTo(
      size.width * 0.7527170,
      size.height * 0.5144151,
      size.width * 0.7596462,
      size.height * 0.5077217,
      size.width * 0.7679434,
      size.height * 0.5077217);
  path_0.close();
  path_0.moveTo(size.width * 0.7278585, size.height * 0.6408585);
  path_0.lineTo(size.width * 0.9118915, size.height * 0.7471132);
  path_0.cubicTo(
      size.width * 0.9193066,
      size.height * 0.7513962,
      size.width * 0.9217217,
      size.height * 0.7608349,
      size.width * 0.9171792,
      size.height * 0.7678868);
  path_0.cubicTo(
      size.width * 0.8786745,
      size.height * 0.8276840,
      size.width * 0.8276792,
      size.height * 0.8786792,
      size.width * 0.7678821,
      size.height * 0.9171840);
  path_0.cubicTo(
      size.width * 0.7608302,
      size.height * 0.9217264,
      size.width * 0.7513868,
      size.height * 0.9193113,
      size.width * 0.7471038,
      size.height * 0.9118915);
  path_0.lineTo(size.width * 0.6408538, size.height * 0.7278632);
  path_0.cubicTo(
      size.width * 0.6367123,
      size.height * 0.7206840,
      size.width * 0.6390283,
      size.height * 0.7113396,
      size.width * 0.6460566,
      size.height * 0.7063538);
  path_0.cubicTo(
      size.width * 0.6693868,
      size.height * 0.6897972,
      size.width * 0.6897925,
      size.height * 0.6693915,
      size.width * 0.7063491,
      size.height * 0.6460613);
  path_0.cubicTo(
      size.width * 0.7113396,
      size.height * 0.6390377,
      size.width * 0.7206792,
      size.height * 0.6367170,
      size.width * 0.7278585,
      size.height * 0.6408585);
  path_0.close();
  path_0.moveTo(size.width * 0.6265802, size.height * 0.7361509);
  path_0.lineTo(size.width * 0.7328302, size.height * 0.9201840);
  path_0.cubicTo(
      size.width * 0.7371085,
      size.height * 0.9275943,
      size.width * 0.7344906,
      size.height * 0.9369670,
      size.width * 0.7270472,
      size.height * 0.9408113);
  path_0.cubicTo(
      size.width * 0.6654481,
      size.height * 0.9726368,
      size.width * 0.5963302,
      size.height * 0.9919481,
      size.width * 0.5230566,
      size.height * 0.9953774);
  path_0.cubicTo(
      size.width * 0.5146840,
      size.height * 0.9957689,
      size.width * 0.5077217,
      size.height * 0.9889575,
      size.width * 0.5077217,
      size.height * 0.9804009);
  path_0.lineTo(size.width * 0.5077217, size.height * 0.7679434);
  path_0.cubicTo(
      size.width * 0.5077217,
      size.height * 0.7596462,
      size.width * 0.5144151,
      size.height * 0.7527170,
      size.width * 0.5230000,
      size.height * 0.7519245);
  path_0.cubicTo(
      size.width * 0.5521462,
      size.height * 0.7492406,
      size.width * 0.5798726,
      size.height * 0.7416226,
      size.width * 0.6053208,
      size.height * 0.7299151);
  path_0.cubicTo(
      size.width * 0.6131604,
      size.height * 0.7263066,
      size.width * 0.6224292,
      size.height * 0.7289670,
      size.width * 0.6265802,
      size.height * 0.7361509);
  path_0.close();
  path_0.moveTo(size.width * 0.4912123, size.height * 0.7679434);
  path_0.lineTo(size.width * 0.4912123, size.height * 0.9804009);
  path_0.cubicTo(
      size.width * 0.4912123,
      size.height * 0.9889575,
      size.width * 0.4842500,
      size.height * 0.9957689,
      size.width * 0.4758774,
      size.height * 0.9953774);
  path_0.cubicTo(
      size.width * 0.4025972,
      size.height * 0.9919481,
      size.width * 0.3334774,
      size.height * 0.9726368,
      size.width * 0.2718759,
      size.height * 0.9408066);
  path_0.cubicTo(
      size.width * 0.2644354,
      size.height * 0.9369623,
      size.width * 0.2618184,
      size.height * 0.9275896,
      size.width * 0.2660962,
      size.height * 0.9201840);
  path_0.lineTo(size.width * 0.3723476, size.height * 0.7361509);
  path_0.cubicTo(
      size.width * 0.3764967,
      size.height * 0.7289623,
      size.width * 0.3857651,
      size.height * 0.7263066,
      size.width * 0.3936028,
      size.height * 0.7299104);
  path_0.cubicTo(
      size.width * 0.4190561,
      size.height * 0.7416226,
      size.width * 0.4467816,
      size.height * 0.7492406,
      size.width * 0.4759340,
      size.height * 0.7519245);
  path_0.cubicTo(
      size.width * 0.4845189,
      size.height * 0.7527170,
      size.width * 0.4912123,
      size.height * 0.7596462,
      size.width * 0.4912123,
      size.height * 0.7679434);
  path_0.close();
  path_0.moveTo(size.width * 0.3580717, size.height * 0.7278585);
  path_0.lineTo(size.width * 0.2518208, size.height * 0.9118915);
  path_0.cubicTo(
      size.width * 0.2475377,
      size.height * 0.9193066,
      size.width * 0.2380962,
      size.height * 0.9217217,
      size.width * 0.2310448,
      size.height * 0.9171792);
  path_0.cubicTo(
      size.width * 0.1712509,
      size.height * 0.8786745,
      size.width * 0.1202580,
      size.height * 0.8276840,
      size.width * 0.08175377,
      size.height * 0.7678915);
  path_0.cubicTo(
      size.width * 0.07721321,
      size.height * 0.7608396,
      size.width * 0.07962642,
      size.height * 0.7513962,
      size.width * 0.08704481,
      size.height * 0.7471132);
  path_0.lineTo(size.width * 0.2710769, size.height * 0.6408632);
  path_0.cubicTo(
      size.width * 0.2782542,
      size.height * 0.6367217,
      size.width * 0.2875967,
      size.height * 0.6390377,
      size.width * 0.2925830,
      size.height * 0.6460660);
  path_0.cubicTo(
      size.width * 0.3091415,
      size.height * 0.6693915,
      size.width * 0.3295448,
      size.height * 0.6897925,
      size.width * 0.3528708,
      size.height * 0.7063491);
  path_0.cubicTo(
      size.width * 0.3598958,
      size.height * 0.7113396,
      size.width * 0.3622156,
      size.height * 0.7206792,
      size.width * 0.3580717,
      size.height * 0.7278585);
  path_0.close();
  path_0.moveTo(size.width * 0.2627840, size.height * 0.6265896);
  path_0.lineTo(size.width * 0.07875142, size.height * 0.7328396);
  path_0.cubicTo(
      size.width * 0.07134198,
      size.height * 0.7371179,
      size.width * 0.06197264,
      size.height * 0.7345000,
      size.width * 0.05812783,
      size.height * 0.7270613);
  path_0.cubicTo(
      size.width * 0.02629505,
      size.height * 0.6654575,
      size.width * 0.006981509,
      size.height * 0.5963349,
      size.width * 0.003554024,
      size.height * 0.5230566);
  path_0.cubicTo(
      size.width * 0.003162368,
      size.height * 0.5146792,
      size.width * 0.009972642,
      size.height * 0.5077217,
      size.width * 0.01853071,
      size.height * 0.5077217);
  path_0.lineTo(size.width * 0.2309873, size.height * 0.5077217);
  path_0.cubicTo(
      size.width * 0.2392830,
      size.height * 0.5077217,
      size.width * 0.2462156,
      size.height * 0.5144151,
      size.width * 0.2470061,
      size.height * 0.5230000);
  path_0.cubicTo(
      size.width * 0.2496896,
      size.height * 0.5521509,
      size.width * 0.2573094,
      size.height * 0.5798774,
      size.width * 0.2690222,
      size.height * 0.6053349);
  path_0.cubicTo(
      size.width * 0.2726288,
      size.height * 0.6131698,
      size.width * 0.2699708,
      size.height * 0.6224387,
      size.width * 0.2627840,
      size.height * 0.6265896);
  path_0.close();
  path_0.moveTo(size.width * 0.2309873, size.height * 0.4912123);
  path_0.lineTo(size.width * 0.01853071, size.height * 0.4912123);
  path_0.cubicTo(
      size.width * 0.009972642,
      size.height * 0.4912123,
      size.width * 0.003162373,
      size.height * 0.4842500,
      size.width * 0.003554028,
      size.height * 0.4758774);
  path_0.cubicTo(
      size.width * 0.006981509,
      size.height * 0.4025962,
      size.width * 0.02629462,
      size.height * 0.3334755,
      size.width * 0.05812642,
      size.height * 0.2718736);
  path_0.cubicTo(
      size.width * 0.06197123,
      size.height * 0.2644335,
      size.width * 0.07134104,
      size.height * 0.2618165,
      size.width * 0.07875000,
      size.height * 0.2660939);
  path_0.lineTo(size.width * 0.2627830, size.height * 0.3723453);
  path_0.cubicTo(
      size.width * 0.2699698,
      size.height * 0.3764948,
      size.width * 0.2726278,
      size.height * 0.3857627,
      size.width * 0.2690212,
      size.height * 0.3936009);
  path_0.cubicTo(
      size.width * 0.2573090,
      size.height * 0.4190547,
      size.width * 0.2496896,
      size.height * 0.4467811,
      size.width * 0.2470061,
      size.height * 0.4759340);
  path_0.cubicTo(
      size.width * 0.2462156,
      size.height * 0.4845189,
      size.width * 0.2392830,
      size.height * 0.4912123,
      size.width * 0.2309873,
      size.height * 0.4912123);
  path_0.close();
  path_0.moveTo(size.width * 0.2710755, size.height * 0.3580693);
  path_0.lineTo(size.width * 0.08704340, size.height * 0.2518189);
  path_0.cubicTo(
      size.width * 0.07962500,
      size.height * 0.2475358,
      size.width * 0.07721226,
      size.height * 0.2380943,
      size.width * 0.08175283,
      size.height * 0.2310429);
  path_0.cubicTo(
      size.width * 0.1202575,
      size.height * 0.1712472,
      size.width * 0.1712524,
      size.height * 0.1202528,
      size.width * 0.2310491,
      size.height * 0.08174858);
  path_0.cubicTo(
      size.width * 0.2381005,
      size.height * 0.07720849,
      size.width * 0.2475415,
      size.height * 0.07962123,
      size.width * 0.2518245,
      size.height * 0.08703962);
  path_0.lineTo(size.width * 0.3580755, size.height * 0.2710712);
  path_0.cubicTo(
      size.width * 0.3622193,
      size.height * 0.2782491,
      size.width * 0.3598995,
      size.height * 0.2875915,
      size.width * 0.3528745,
      size.height * 0.2925778);
  path_0.cubicTo(
      size.width * 0.3295467,
      size.height * 0.3091368,
      size.width * 0.3091410,
      size.height * 0.3295415,
      size.width * 0.2925821,
      size.height * 0.3528689);
  path_0.cubicTo(
      size.width * 0.2875953,
      size.height * 0.3598939,
      size.width * 0.2782528,
      size.height * 0.3622137,
      size.width * 0.2710755,
      size.height * 0.3580693);
  path_0.close();

  return path_0;
}
