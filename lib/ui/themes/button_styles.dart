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

final buttonBackgroundDarkGrey = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.white140;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.black90;
    }
    return AbiliaColors.black80;
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
  textStyle: MaterialStateProperty.all(
    abiliaTextTheme.subtitle1?.copyWith(height: 1),
  ),
  minimumSize: MaterialStateProperty.all(
      Size.fromHeight(layout.button.baseButtonMinHeight)),
);

final textButtonStyle = baseButtonStyle.copyWith(
  shape: noBorder,
  padding: MaterialStateProperty.all(
    layout.button.textButtonInsets,
  ),
);

final textButtonStyleGreen = textButtonStyle.copyWith(
  backgroundColor: buttonBackgroundGreen,
);

final textButtonStyleDarkGrey = textButtonStyle.copyWith(
  backgroundColor: buttonBackgroundDarkGrey,
);

final iconTextButtonStyle = baseButtonStyle.copyWith(
  minimumSize: MaterialStateProperty.all(layout.iconTextButton.minimumSize),
  maximumSize: MaterialStateProperty.all(layout.iconTextButton.maximumSize),
);

final iconTextButtonStyleLight = iconTextButtonStyle.copyWith(
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

final iconTextButtonStyleNext = iconTextButtonStyleGreen.copyWith(
  minimumSize: MaterialStateProperty.all(layout.nextButton.minimumSize),
  maximumSize: MaterialStateProperty.all(layout.nextButton.maximumSize),
);

final actionIconTextButtonStyleRed = ButtonStyle(
  foregroundColor: MaterialStateProperty.all(AbiliaColors.white),
  textStyle:
      MaterialStateProperty.all(abiliaTextTheme.bodyText1?.copyWith(height: 1)),
  minimumSize: MaterialStateProperty.all(layout.button.redButtonMinSize),
  padding: MaterialStateProperty.all(
    layout.button.redButtonPadding,
  ),
  backgroundColor: buttonBackgroundRed,
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return noBorderShape;
      }
      return RoundedRectangleBorder(
        borderRadius: borderRadius,
        side:
            BorderSide(color: AbiliaColors.red140, width: layout.borders.thin),
      );
    },
  ),
);

final double secondaryActionButtonMinSize =
    layout.button.secondaryActionButtonMinSize;

final _actionButtonStyle = ButtonStyle(
  textStyle: MaterialStateProperty.all(abiliaTextTheme.button),
  minimumSize: MaterialStateProperty.all(
      Size(layout.actionButton.size, layout.actionButton.size)),
  padding: MaterialStateProperty.all(layout.actionButton.padding),
);

final actionButtonStyleRed = _actionButtonStyle.copyWith(
  backgroundColor: buttonBackgroundRed,
  foregroundColor: foregroundLight,
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return noBorderShape;
      }
      return RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: AbiliaColors.red140,
          width: layout.borders.thin,
        ),
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

final secondaryActionButtonStyleDark = actionButtonStyleDark.copyWith(
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) return noBorderShape;
    return darkShapeBorder.copyWith(borderRadius: circleRadius);
  }),
  minimumSize: MaterialStateProperty.all(Size(
    secondaryActionButtonMinSize,
    secondaryActionButtonMinSize,
  )),
  fixedSize: MaterialStateProperty.all(Size(
    secondaryActionButtonMinSize,
    secondaryActionButtonMinSize,
  )),
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

final actionButtonStyleLightSelected = _actionButtonStyle.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.transparentWhite40;
      }
      return AbiliaColors.white;
    },
  ),
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.transparentBlack40;
      }
      return AbiliaColors.black;
    },
  ),
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    return noBorderShape;
  }),
);

final _textActionButtonStyle = ButtonStyle(
  textStyle:
      MaterialStateProperty.all(abiliaTextTheme.caption?.copyWith(height: 1)),
  maximumSize: MaterialStateProperty.all(
      Size(layout.actionButton.size, layout.actionButton.size)),
  padding: MaterialStateProperty.all(layout.actionButton.withTextPadding),
);

final textActionButtonStyleLight =
    _textActionButtonStyle.merge(actionButtonStyleLight);

final textActionButtonStyleLightSelected =
    _textActionButtonStyle.merge(actionButtonStyleLightSelected);

final secondaryActionButtonStyleLight = actionButtonStyleLight.copyWith(
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) return noBorderShape;
    return ligthShapeBorder.copyWith(borderRadius: circleRadius);
  }),
  minimumSize: MaterialStateProperty.all(Size(
    secondaryActionButtonMinSize,
    secondaryActionButtonMinSize,
  )),
  fixedSize: MaterialStateProperty.all(Size(
    secondaryActionButtonMinSize,
    secondaryActionButtonMinSize,
  )),
);

ButtonStyle tabButtonStyle({
  required BorderRadius borderRadius,
  required bool isSelected,
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
                side: const BorderSide(color: AbiliaColors.transparentBlack30),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(AbiliaColors.transparentBlack20),
            foregroundColor: MaterialStateProperty.all(AbiliaColors.black),
          );

final ButtonStyle blueButtonStyle = _ButtonDef(
  background: _StateColors(
    def: AbiliaColors.blue,
    disabled: AbiliaColors.blue,
    pressed: AbiliaColors.blue,
  ),
  foreGround: _StateColors(
    def: AbiliaColors.white,
    disabled: AbiliaColors.white,
    pressed: AbiliaColors.white,
  ),
  shapeBorders: _ShapeBorders(
    def: menuButtonBorder,
    pressedOrDisabled: noBorderShape,
  ),
).toStyle();

final ButtonStyle pinkButtonStyle = _ButtonDef(
  background: _StateColors(
    def: AbiliaColors.pink40,
    disabled: AbiliaColors.pink40,
    pressed: AbiliaColors.pink40,
  ),
  foreGround: _StateColors(
    def: AbiliaColors.white,
    disabled: AbiliaColors.white,
    pressed: AbiliaColors.white,
  ),
  shapeBorders: _ShapeBorders(
    def: menuButtonBorder,
    pressedOrDisabled: noBorderShape,
  ),
).toStyle();

final ButtonStyle yellowButtonStyle = _ButtonDef(
  background: _StateColors(
    def: AbiliaColors.yellow,
    disabled: AbiliaColors.yellow,
    pressed: AbiliaColors.yellow,
  ),
  foreGround: _StateColors(
    def: AbiliaColors.black,
    disabled: AbiliaColors.black,
    pressed: AbiliaColors.black,
  ),
  shapeBorders: _ShapeBorders(
    def: menuButtonBorder,
    pressedOrDisabled: noBorderShape,
  ),
).toStyle();

final ButtonStyle blackButtonStyle = actionButtonStyleBlack.copyWith(
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) {
      return noBorderShape;
    }
    return menuButtonBorder;
  }),
);

final ButtonStyle keyboardButtonStyle = ButtonStyle(
  textStyle: MaterialStateProperty.all(abiliaTextTheme.headline6),
  fixedSize: MaterialStateProperty.all(Size(
      layout.timeInput.keyboardButtonWidth,
      layout.timeInput.keyboardButtonHeight)),
  foregroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.white140;
      }
      return AbiliaColors.black;
    },
  ),
  shape: MaterialStateProperty.all(noBorderShape),
);

final ButtonStyle keyboardNumberButtonStyle = keyboardButtonStyle.copyWith(
  shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) ||
        states.contains(MaterialState.pressed)) {
      return noBorderShape;
    }
    return menuButtonBorder;
  }),
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
);

final ButtonStyle keyboardActionButtonStyle = keyboardButtonStyle.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith<Color>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return AbiliaColors.transparentWhite40;
      }
      if (states.contains(MaterialState.pressed)) {
        return AbiliaColors.white120;
      }
      return AbiliaColors.white;
    },
  ),
);

class _ButtonDef {
  final _StateColors foreGround;
  final _StateColors background;
  final _ShapeBorders shapeBorders;

  _ButtonDef({
    required this.foreGround,
    required this.background,
    required this.shapeBorders,
  });

  ButtonStyle toStyle() {
    return _actionButtonStyle.copyWith(
      textStyle: MaterialStateProperty.all(abiliaTextTheme.button),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return foreGround.disabled;
          }
          return foreGround.def;
        },
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return background.disabled;
          }
          if (states.contains(MaterialState.pressed)) {
            return background.pressed;
          }
          return background.def;
        },
      ),
      shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled) ||
            states.contains(MaterialState.pressed)) {
          return shapeBorders.pressedOrDisabled;
        }
        return shapeBorders.def;
      }),
    );
  }
}

class _StateColors {
  final Color disabled;
  final Color pressed;
  final Color def;

  _StateColors({
    required this.disabled,
    required this.pressed,
    required this.def,
  });
}

class _ShapeBorders {
  final OutlinedBorder pressedOrDisabled;
  final OutlinedBorder def;

  _ShapeBorders({
    required this.pressedOrDisabled,
    required this.def,
  });
}
