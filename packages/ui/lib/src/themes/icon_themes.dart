import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/numericals.dart';

const iconThemeError = IconTheme(
  data: IconThemeData(size: numerical600),
  child: Icon(Symbols.error),
);

final iconThemeSuccess = IconTheme(
  data: IconThemeData(
    fill: 1.0,
    color: SurfaceColors.positiveSelected,
    size: numerical600,
  ),
  child: const Icon(Symbols.check_circle),
);
