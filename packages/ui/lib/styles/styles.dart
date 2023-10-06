import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

const _baseBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(numerical200)));
const _roundBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(numerical500)));
const _peach400BorderSide =
    BorderSide(color: AbiliaColors.peach400, width: numerical2);
const _grey300BorderSide =
    BorderSide(color: AbiliaColors.greyscale300, width: numerical2);

final actionButtonPrimary1000 = ButtonStyle(
  iconSize: MaterialStateProperty.all(numerical800),
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
  textStyle: MaterialStateProperty.all(primary525),
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return _baseBorder.copyWith(side: _peach400BorderSide);
    }
    return _baseBorder;
  }),
  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
      horizontal: numerical600, vertical: numerical300)),
);

final actionButtonPrimary900 = actionButtonPrimary1000.copyWith(
  textStyle: MaterialStateProperty.all(primary425),
  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
      horizontal: numerical400, vertical: numerical300)),
);

final actionButtonSecondary1000 = actionButtonPrimary1000.copyWith(
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

final actionButtonSecondary900 = actionButtonSecondary1000.copyWith(
  textStyle: MaterialStateProperty.all(primary425),
  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
      horizontal: numerical400, vertical: numerical300)),
);

final actionButtonTertiary1000 = actionButtonPrimary1000.copyWith(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
), foregroundColor: MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return FontColors.secondary;
    }
    return FontColors.primary;
  },
), shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
  if (states.contains(MaterialState.focused)) {
    return _baseBorder.copyWith(side: _peach400BorderSide);
  }
  if (states.contains(MaterialState.hovered)) {
    return _baseBorder.copyWith(side: _grey300BorderSide);
  }
  return _baseBorder;
}));

final actionButtonTertiary900 = actionButtonTertiary1000.copyWith(
  textStyle: MaterialStateProperty.all(primary425),
  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
      horizontal: numerical400, vertical: numerical300)),
);

final actionButtonTertiary800 = actionButtonTertiary900.copyWith(
    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
        horizontal: numerical300, vertical: numerical200)),
    shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) {
        return _roundBorder.copyWith(side: _peach400BorderSide);
      }
      if (states.contains(MaterialState.hovered)) {
        return _roundBorder.copyWith(side: _grey300BorderSide);
      }
      return _roundBorder;
    }));
