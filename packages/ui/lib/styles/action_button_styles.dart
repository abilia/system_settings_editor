part of 'styles.dart';

final actionButtonPrimaryMedium = ButtonStyle(
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

final actionButtonSecondaryMedium = actionButtonPrimaryMedium.copyWith(
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

final actionButtonTertiaryMedium = actionButtonPrimaryMedium.copyWith(
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
        return _baseBorder.copyWith(side: borderSideGrey300);
      }
      return _baseBorder;
    },
  ),
);

final actionButtonPrimarySmall = actionButtonPrimaryMedium.copyWith(
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
        return _roundBorder.copyWith(side: borderSideGrey300);
      }
      return _roundBorder;
    },
  ),
);

final actionButtonSecondarySmall = actionButtonSecondaryMedium.copyWith(
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
        return _roundBorder.copyWith(side: borderSideGrey300);
      }
      return _roundBorder;
    },
  ),
);

final actionButtonTertiarySmall = actionButtonTertiaryMedium.copyWith(
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
        return _roundBorder.copyWith(side: borderSideGrey300);
      }
      return _roundBorder;
    },
  ),
);
