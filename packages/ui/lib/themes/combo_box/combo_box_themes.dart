import 'package:flutter/material.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/numericals.dart';

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
