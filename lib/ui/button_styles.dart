import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

final buttonBackgroundLight = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return Colors.transparent;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.transparentWhite40;
    }
    return AbiliaColors.transparentWhite20;
  },
);
final foregroundLight = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.transparentWhite40;
    }
    return AbiliaColors.white;
  },
);

final buttonBackgroundRed = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.red40;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.red120;
    }
    return AbiliaColors.red;
  },
);

final buttonBackgroundGreen = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.green40;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.green120;
    }
    return AbiliaColors.green;
  },
);

final noBorderShape = RoundedRectangleBorder(borderRadius: borderRadius);
final noBorder = MaterialStateProperty.all(noBorderShape);

final baseButtonStyle = ButtonStyle(
  foregroundColor: MaterialStateProperty.all(AbiliaColors.white),
  textStyle: MaterialStateProperty.all(abiliaTextTheme.subtitle1),
  minimumSize: MaterialStateProperty.all(Size.fromHeight(64.0.s)),
);

final textButtonStyleRed = baseButtonStyle.copyWith(
  backgroundColor: buttonBackgroundRed,
  shape: noBorder,
  padding: MaterialStateProperty.all(
    EdgeInsets.symmetric(horizontal: 32.s, vertical: 20.s),
  ),
);

final iconTextButtonStyle = baseButtonStyle.copyWith(
  padding: MaterialStateProperty.all(
    EdgeInsets.fromLTRB(0.0, 20.s, 8.0.s, 20.0.s),
  ),
  minimumSize: MaterialStateProperty.all(Size(172.0.s, 64.0.s)),
);

final iconTextButtonStyleDarkGrey = iconTextButtonStyle.copyWith(
  backgroundColor: buttonBackgroundLight,
  shape: MaterialStateProperty.all(ligthShapeBorder),
);

final iconTextButtonStyleGreen = iconTextButtonStyle.copyWith(
  backgroundColor: buttonBackgroundGreen,
  shape: noBorder,
);

final iconTextButtonStyleRed = iconTextButtonStyle.copyWith(
  backgroundColor: buttonBackgroundRed,
  shape: noBorder,
);

final actionIconTextButtonStyleRed = ButtonStyle(
  foregroundColor: MaterialStateProperty.all(AbiliaColors.white),
  textStyle: MaterialStateProperty.all(abiliaTextTheme.bodyText1),
  minimumSize: MaterialStateProperty.all(Size(0.0, 48.0.s)),
  padding: MaterialStateProperty.all(
    EdgeInsets.fromLTRB(10.0.s, 10.0.s, 20.0.s, 10.0.s),
  ),
  backgroundColor: buttonBackgroundRed,
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return noBorderShape;
      }
      return RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: AbiliaColors.red140, width: 1.0.s),
      );
    },
  ),
);

final double actionButtonMinSize = 48.0.s;

final _actionButtonStyle = ButtonStyle(
  minimumSize:
      MaterialStateProperty.all(Size(actionButtonMinSize, actionButtonMinSize)),
  padding: MaterialStateProperty.all(EdgeInsets.all(8.0.s)),
);

final actionButtonStyleRed = _actionButtonStyle.copyWith(
  backgroundColor: buttonBackgroundRed,
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return noBorderShape;
      }
      return RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: AbiliaColors.red140, width: 1.0.s),
      );
    },
  ),
);

final actionButtonStyleDark = _actionButtonStyle.copyWith(
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.white140;
      }
      return AbiliaColors.black;
    },
  ),
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.transparentBlack40;
      }
      return AbiliaColors.transparentBlack20;
    },
  ),
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) {
      return noBorderShape;
    }
    return darkShapeBorder;
  }),
);

final actionButtonStyleBlack = _actionButtonStyle.copyWith(
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.transparentWhite40;
      }
      return AbiliaColors.white;
    },
  ),
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.white140;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.black;
      }
      return AbiliaColors.black80;
    },
  ),
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) {
      return noBorderShape;
    }
    return darkShapeBorder;
  }),
);

final actionButtonStyleLight = _actionButtonStyle.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.transparentWhite40;
      }
      return AbiliaColors.transparentWhite20;
    },
  ),
  foregroundColor: foregroundLight,
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) {
      return noBorderShape;
    }
    return ligthShapeBorder;
  }),
);

ButtonStyle tabButtonStyle({
  BorderRadius borderRadius,
  bool isSelected,
}) =>
    isSelected
        ? ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: borderRadius, side: BorderSide.none),
            ),
            backgroundColor: MaterialStateProperty.all(AbiliaColors.green),
            foregroundColor: MaterialStateProperty.all(AbiliaColors.white),
          )
        : ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(color: AbiliaColors.transparentBlack30),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(AbiliaColors.transparentBlack20),
            foregroundColor: MaterialStateProperty.all(AbiliaColors.black),
          );
