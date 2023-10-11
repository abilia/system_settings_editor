import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

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

final actionButtonPrimary900 = ButtonStyle(
  iconSize: MaterialStateProperty.all(numerical600),
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.greyscale300;
      }
      if (states.contains(MaterialState.hovered)) {
        return AbiliaColors.primary600;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.primary700;
      }
      if (states.contains(MaterialState.focused)) {
        return AbiliaColors.primary500;
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
  textStyle: MaterialStateProperty.all(AbiliaFonts.primary425),
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) {
        return _baseBorder.copyWith(side: _borderSidePeach400);
      }
      return _baseBorder;
    },
  ),
  padding: MaterialStateProperty.all(
    const EdgeInsets.symmetric(
      horizontal: numerical400,
      vertical: numerical300,
    ),
  ),
);

final actionButtonSecondary900 = actionButtonPrimary900.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.greyscale300;
      }
      if (states.contains(MaterialState.hovered)) {
        return AbiliaColors.secondary500;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.secondary600;
      }
      return AbiliaColors.secondary400;
    },
  ),
);

final actionButtonTertiary900 = actionButtonPrimary900.copyWith(
  backgroundColor: _backgroundGrey,
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return FontColors.secondary;
      }
      return FontColors.primary;
    },
  ),
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) {
        return _baseBorder.copyWith(side: _borderSidePeach400);
      }
      if (states.contains(MaterialState.hovered)) {
        return _baseBorder.copyWith(side: _borderSideGrey300);
      }
      return _baseBorder;
    },
  ),
);

final actionButtonTertiary800 = actionButtonTertiary900.copyWith(
  padding: MaterialStateProperty.all(
    const EdgeInsets.symmetric(
      horizontal: numerical300,
      vertical: numerical200,
    ),
  ),
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) {
        return _roundBorder.copyWith(side: _borderSidePeach400);
      }
      if (states.contains(MaterialState.hovered)) {
        return _roundBorder.copyWith(side: _borderSideGrey300);
      }
      return _roundBorder;
    },
  ),
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
