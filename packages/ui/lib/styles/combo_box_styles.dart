import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

final inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: borderSideGrey300.copyWith(width: numerical1px));

final activeBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: borderSideGrey300.copyWith(
        width: numerical1px, color: BorderColors.active));

final errorBorder = OutlineInputBorder(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  borderSide: borderSideGrey300.copyWith(
      width: numerical1px, color: BorderColors.focus),
);

final textFieldTextStyleMedium =
    MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
  if (states.contains(MaterialState.error)) {
    return AbiliaFonts.primary425;
  }
  if (states.contains(MaterialState.focused)) {
    return AbiliaFonts.primary425;
  }
  return AbiliaFonts.primary425.copyWith(color: FontColors.secondary);
});

final textFieldTextStyleLarge =
    MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
  if (states.contains(MaterialState.error)) {
    return AbiliaFonts.primary525;
  }
  if (states.contains(MaterialState.focused)) {
    return AbiliaFonts.primary525;
  }
  return AbiliaFonts.primary525.copyWith(color: FontColors.secondary);
});
