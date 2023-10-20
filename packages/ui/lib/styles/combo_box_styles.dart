import 'package:flutter/material.dart';
import 'package:ui/src/colors.dart';
import 'package:ui/src/fonts.dart';
import 'package:ui/src/numericals.dart';

final borderSideGrey300 = BorderSide(
  color: SurfaceColors.active,
  width: numerical2px,
);

final inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: borderSideGrey300.copyWith(width: numerical1px));

final activeBorder = inputBorder.copyWith(
    borderSide: borderSideGrey300.copyWith(
        width: numerical1px, color: SurfaceColors.borderActive));

final errorBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
      width: numerical1px, color: SurfaceColors.borderFocus),
);

final successBorder = inputBorder.copyWith(
    borderSide: borderSideGrey300.copyWith(
        width: numerical1px, color: SurfaceColors.positiveSelected));

final textFieldTextStyleMedium =
    MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
  if (states.contains(MaterialState.error)) {
    return AbiliaFonts.primary425;
  }
  if (states.contains(MaterialState.focused)) {
    return AbiliaFonts.primary425;
  }
  return AbiliaFonts.primary425.copyWith(color: SurfaceColors.textSecondary);
});

final textFieldTextStyleLarge =
    MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
  if (states.contains(MaterialState.error)) {
    return AbiliaFonts.primary525;
  }
  if (states.contains(MaterialState.focused)) {
    return AbiliaFonts.primary525;
  }
  return AbiliaFonts.primary525.copyWith(color: SurfaceColors.textSecondary);
});
