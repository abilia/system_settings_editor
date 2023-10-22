import 'package:flutter/material.dart';
import 'package:ui/src/styles/borders.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/fonts.dart';
import 'package:ui/src/tokens/numericals.dart';
import 'package:ui/themes/abilia_text_style_themes.dart';

final textFieldInputTheme700 = InputDecorationTheme(
  fillColor: MaterialStateColor.resolveWith(
    (states) {
      if (states.contains(MaterialState.disabled) &&
          states.contains(MaterialState.hovered)) {
        return SurfaceColors.hoverSubdued;
      }
      if (states.contains(MaterialState.disabled)) {
        return SurfaceColors.subdued;
      }
      if (states.contains(MaterialState.hovered)) {
        return SurfaceColors.hover;
      }
      return SurfaceColors.primary;
    },
  ),
  filled: true,
  border: inputBorder,
  errorBorder: errorBorder,
  focusedBorder: activeBorder,
  focusedErrorBorder: errorBorder,
  enabledBorder: inputBorder,
  hintStyle: AbiliaFonts.primary425.withColor(SurfaceColors.textSecondary),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: numerical400,
    vertical: numerical300,
  ),
  constraints: const BoxConstraints(
    maxHeight: numerical900,
    minHeight: numerical900,
  ),
);

final textFieldInputTheme800 = textFieldInputTheme700.copyWith(
  hintStyle: AbiliaFonts.primary525.withColor(SurfaceColors.textSecondary),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: numerical400,
    vertical: numerical500,
  ),
  constraints: const BoxConstraints(
    maxHeight: numerical1000,
    minHeight: numerical1000,
  ),
);
