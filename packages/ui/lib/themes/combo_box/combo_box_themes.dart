import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/src/colors.dart';
import 'package:ui/src/numericals.dart';
import 'package:ui/styles/combo_box_styles.dart';

final textFieldInputThemeMedium = InputDecorationTheme(
  fillColor: MaterialStateColor.resolveWith(
    (states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.peach.shade300;
      }
      return AbiliaColors.greyscale.shade000;
    },
  ),
  filled: true,
  border: inputBorder,
  errorBorder: errorBorder,
  focusedBorder: activeBorder,
  focusedErrorBorder: errorBorder,
  enabledBorder: inputBorder,
  contentPadding: const EdgeInsets.symmetric(
    horizontal: numerical400,
    vertical: numerical300,
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

const comboBoxBoxShadow = BoxShadow(
  color: AbiliaColors.primary,
  spreadRadius: numerical200,
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
