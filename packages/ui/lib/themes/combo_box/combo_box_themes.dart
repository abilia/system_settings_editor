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
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: borderSideGrey300.copyWith(width: numerical1px),
  ),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: numerical400,
    vertical: numerical300,
  ),
);
