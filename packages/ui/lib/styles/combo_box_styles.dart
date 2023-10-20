import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/src/colors.dart';
import 'package:ui/src/fonts.dart';
import 'package:ui/src/numericals.dart';
import 'package:ui/themes/abilia_text_style_themes.dart';

final borderSideGrey300 = BorderSide(
  color: SurfaceColors.active,
  width: numerical2px,
);

final inputBorder = OutlineInputBorder(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  borderSide: borderSideGrey300.copyWith(width: numerical1px),
);

final activeBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
    color: SurfaceColors.borderActive,
  ),
);

final errorBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
    color: SurfaceColors.borderFocus,
  ),
);

final successBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
    color: SurfaceColors.positiveSelected,
  ),
);

final textFieldInputThemeMedium = InputDecorationTheme(
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
    vertical: numerical300,
  ),
  constraints: const BoxConstraints(
    maxHeight: numerical900,
    minHeight: numerical900,
  ),
);

final textFieldInputThemeLarge = textFieldInputThemeMedium.copyWith(
  hintStyle: AbiliaFonts.primary525.withColor(SurfaceColors.textSecondary),
  contentPadding: const EdgeInsets.symmetric(
    vertical: numerical500,
  ),
  constraints: const BoxConstraints(
    maxHeight: numerical1000,
    minHeight: numerical1000,
  ),
);

final textFieldBoxDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  color: MaterialStateColor.resolveWith(
    (states) {
      if (states.contains(MaterialState.disabled)) {
        return SurfaceColors.subdued;
      }
      return SurfaceColors.primary;
    },
  ),
);

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
