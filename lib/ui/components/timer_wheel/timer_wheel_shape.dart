import 'dart:math';
import 'dart:ui';
import 'package:matrix4_transform/matrix4_transform.dart';

Path getWheelShape(Size size) {
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
    ..cubicTo(controlA2.dx, controlA2.dy, controlB1.dx, controlB1.dy, pointB.dx,
        pointB.dy)
    ..lineTo(pointC.dx, pointC.dy) // ok
    ..cubicTo(controlC1.dx, controlC1.dy, controlD1.dx, controlD1.dy, pointD.dx,
        pointD.dy)
    ..cubicTo(controlD2.dx, controlD2.dy, controlE1.dx, controlE1.dy, pointE.dx,
        pointE.dy)
    ..cubicTo(controlE2.dx, controlE2.dy, controlF1.dx, controlF1.dy, pointF.dx,
        pointF.dy)
    ..lineTo(pointG.dx, pointG.dy) // ok
    ..cubicTo(controlG1.dx, controlG1.dy, controlH1.dx, controlH1.dy, pointH.dx,
        pointH.dy)
    ..cubicTo(controlH2.dx, controlH2.dy, controlA1.dx, controlA1.dy, pointA.dx,
        pointA.dy)
    ..close();

  final timerWheelShape = Path();

  for (int i = 0; i < 12; i++) {
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
