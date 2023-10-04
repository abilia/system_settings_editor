import 'dart:ui';

import 'package:ui/tokens/colors.dart';

class Elevation {
  final int yDistance;
  final int blur;
  final Color color;
  final double alpha;

  const Elevation(
      {required this.yDistance,
      required this.blur,
      required this.color,
      required this.alpha});

  Elevation copyWith({int? yDistance, int? blur, Color? color, double? alpha}) {
    return Elevation(
        yDistance: yDistance ?? this.yDistance,
        blur: blur ?? this.blur,
        color: color ?? this.color,
        alpha: alpha ?? this.alpha);
  }
}

const elevation100 = Elevation(
    yDistance: 2, blur: 4, color: AbiliaColors.greyscale1000, alpha: 0.1);
const elevation200 = Elevation(
    yDistance: 4, blur: 8, color: AbiliaColors.greyscale1000, alpha: 0.1);
const elevation300 = Elevation(
    yDistance: 8, blur: 16, color: AbiliaColors.greyscale1000, alpha: 0.1);
final elevation400 = elevation100.copyWith(alpha: 0.3);
final elevation500 = elevation200.copyWith(alpha: 0.3);
final elevation600 = elevation300.copyWith(alpha: 0.3);
final elevationInverted100 = elevation400.copyWith(alpha: 0.3);
