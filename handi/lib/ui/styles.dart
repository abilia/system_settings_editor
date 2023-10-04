import 'package:flutter/material.dart';
import 'package:handi/ui/layout/tokens/colors.dart';
import 'package:handi/ui/layout/tokens/fonts.dart';
import 'package:handi/ui/layout/tokens/numericals.dart';

final actionButtonStyleLarge = ButtonStyle(
  iconSize: MaterialStateProperty.all(numerical1800),
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return HandiColors.greyscale300;
      }
      if (states.contains(MaterialState.pressed)) {
        return HandiColors.primary700;
      }
      return HandiColors.primary500;
    },
  ),
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return FontColors.secondary;
      }
      return HandiColors.greyscale000;
    },
  ),
  textStyle: MaterialStateProperty.all(primary525),
  minimumSize: MaterialStateProperty.all(const Size(186.0, 64)),
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    return const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(numerical200)));
  }),
  // textStyle: MaterialStateProperty.all(primary525),
);
