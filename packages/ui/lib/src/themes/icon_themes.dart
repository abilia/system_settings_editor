import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/numericals.dart';

final comboBoxIconThemeData800 = IconThemeData(
  size: numerical800,
  color: AbiliaColors.greyscale.shade900,
  weight: 1000,
);
final comboBoxIconThemeData700 = comboBoxIconThemeData800.copyWith(
  size: numerical600,
);

final iconThemeDataSuccess = IconThemeData(
  fill: 1.0,
  color: SurfaceColors.positiveSelected,
);
