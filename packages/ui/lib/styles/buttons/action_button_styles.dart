part of 'button_styles.dart';

final _actionButtonNoBorder1000 = ButtonStyle(
  iconSize: MaterialStateProperty.all(numerical800),
  textStyle: MaterialStateProperty.all(AbiliaFonts.primary525),
  shape: _noBorderShape200,
  elevation: MaterialStateProperty.all(numerical000),
  padding: MaterialStateProperty.all(
    const EdgeInsets.symmetric(
      horizontal: numerical600,
      vertical: numerical300,
    ),
  ),
);

final _actionButtonNoBorder900 = _actionButtonNoBorder1000.copyWith(
  iconSize: MaterialStateProperty.all(numerical600),
  textStyle: MaterialStateProperty.all(AbiliaFonts.primary425),
  padding: MaterialStateProperty.all(
    const EdgeInsets.symmetric(
      horizontal: numerical400,
      vertical: numerical300,
    ),
  ),
);

final _actionButtonNoBorder800 = _actionButtonNoBorder900.copyWith(
  shape: _noBorderShape500,
  padding: MaterialStateProperty.all(
    const EdgeInsets.symmetric(
      horizontal: numerical300,
      vertical: numerical200,
    ),
  ),
);

final _actionButtonBorder1000 = _actionButtonNoBorder1000.copyWith(
  shape: _borderShape200,
);

final _actionButtonBorder900 = _actionButtonNoBorder900.copyWith(
  shape: _borderShape200,
);

final _actionButtonBorder800 = _actionButtonNoBorder800.copyWith(
  shape: _borderShape500,
);

final _actionButtonPrimary = ButtonStyle(
  backgroundColor: _backgroundPrimary,
  foregroundColor: _foregroundColorLightGrey,
);

final _actionButtonSecondary = ButtonStyle(
  backgroundColor: _backgroundSecondary,
  foregroundColor: _foregroundColorLightGrey,
);

final _actionButtonTertiary = ButtonStyle(
  backgroundColor: _backgroundLightGrey,
  foregroundColor: _foregroundColorDarkGrey,
);

final _actionButtonTertiaryNoBorder = ButtonStyle(
  backgroundColor: _backgroundLightGreyTransparent,
  foregroundColor: _foregroundColorDarkGrey,
);

final actionButtonPrimary1000 =
    _actionButtonNoBorder1000.merge(_actionButtonPrimary);

final actionButtonSecondary1000 =
    _actionButtonNoBorder1000.merge(_actionButtonSecondary);

final actionButtonTertiary1000 =
    _actionButtonBorder1000.merge(_actionButtonTertiary);

final actionButtonNoBorderTertiary1000 =
    _actionButtonNoBorder1000.merge(_actionButtonTertiaryNoBorder);

final actionButtonPrimary900 =
    _actionButtonNoBorder900.merge(_actionButtonPrimary);

final actionButtonSecondary900 =
    _actionButtonNoBorder900.merge(_actionButtonSecondary);

final actionButtonTertiary900 =
    _actionButtonBorder900.merge(_actionButtonTertiary);

final actionButtonNoBorderTertiary900 =
    _actionButtonNoBorder900.merge(_actionButtonTertiaryNoBorder);

final actionButtonPrimary800 =
    _actionButtonNoBorder800.merge(_actionButtonPrimary);

final actionButtonSecondary800 =
    _actionButtonNoBorder800.merge(_actionButtonSecondary);

final actionButtonTertiary800 =
    _actionButtonBorder800.merge(_actionButtonTertiary);

final actionButtonNoBorderTertiary800 =
    _actionButtonNoBorder800.merge(_actionButtonTertiaryNoBorder);
