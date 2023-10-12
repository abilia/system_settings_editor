import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

part 'action_button_styles.dart';

const _baseBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(numerical200),
  ),
);
const _roundBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(numerical500),
  ),
);
const _borderSidePeach400 = BorderSide(
  color: AbiliaColors.peach400,
  width: numerical2px,
);
const _borderSideGrey300 = BorderSide(
  color: AbiliaColors.greyscale300,
  width: numerical2px,
);

final _backgroundGrey = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.greyscale300;
    }
    if (states.contains(MaterialState.hovered)) {
      return AbiliaColors.greyscale200;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.greyscale300;
    }
    if (states.contains(MaterialState.focused)) {
      return AbiliaColors.greyscale000;
    }
    return AbiliaColors.greyscale000;
  },
);

final inputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: _borderSideGrey300.copyWith(width: numerical1px));

final activeBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: _borderSideGrey300.copyWith(
        width: numerical1px, color: BorderColors.active));

final errorBorder = OutlineInputBorder(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  borderSide: _borderSideGrey300.copyWith(
      width: numerical1px, color: BorderColors.focus),
);

final textFieldInputTheme900 = InputDecorationTheme(
  fillColor: MaterialStateColor.resolveWith((states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.peach300;
    }
    return AbiliaColors.greyscale000;
  }),
  filled: true,
  border: inputBorder,
  errorBorder: errorBorder,
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(numerical200),
    ),
    borderSide: _borderSideGrey300.copyWith(width: numerical1px),
  ),
  contentPadding: const EdgeInsets.symmetric(
      horizontal: numerical200, vertical: numerical10px),
);

final textFieldTextStyle900 =
    MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
  if (states.contains(MaterialState.error)) {
    return AbiliaFonts.primary425;
  }
  if (states.contains(MaterialState.focused)) {
    return AbiliaFonts.primary425;
  }
  return AbiliaFonts.primary425.copyWith(color: FontColors.secondary);
});
