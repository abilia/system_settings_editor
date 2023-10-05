import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

final actionButtonStyleLarge = ButtonStyle(
  iconSize: MaterialStateProperty.all(numerical800),
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.greyscale300;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.primary700;
      }
      return AbiliaColors.primary500;
    },
  ),
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return FontColors.secondary;
      }
      return AbiliaColors.greyscale000;
    },
  ),
  textStyle: MaterialStateProperty.all(primary525),
  minimumSize:
      MaterialStateProperty.all(const Size(numerical000, numerical000)),
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    return const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(numerical200)));
  }),
  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
      horizontal: numerical600, vertical: numerical300)),
);
