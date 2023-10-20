import 'package:flutter/material.dart';
import 'package:ui/src/styles/borders.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/fonts.dart';
import 'package:ui/src/tokens/numericals.dart';

part 'action_button_styles.dart';
part 'icon_button_styles.dart';

final _borderSidePeach400 = BorderSide(
  color: AbiliaColors.peach.shade400,
  width: numerical2px,
);

final _borderSideGrey300 = BorderSide(
  color: AbiliaColors.greyscale.shade300,
  width: numerical1px,
);

final _padding200 = MaterialStateProperty.all(
  const EdgeInsets.all(numerical200),
);

final _padding300 = MaterialStateProperty.all(
  const EdgeInsets.all(numerical300),
);

final _noBorderShape200 = MaterialStateProperty.resolveWith(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return border200.copyWith(side: _borderSidePeach400);
    }
    return border200;
  },
);

final _noBorderShape300 = MaterialStateProperty.resolveWith(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return border300.copyWith(side: _borderSidePeach400);
    }
    return border300;
  },
);

final _noBorderShape500 = MaterialStateProperty.resolveWith(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.focused)) {
      return border500.copyWith(side: _borderSidePeach400);
    }
    return border500;
  },
);

final _borderShape300 = MaterialStateProperty.resolveWith(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return border300;
    }
    if (states.contains(MaterialState.pressed)) {
      return border300;
    }
    if (states.contains(MaterialState.focused)) {
      return border300.copyWith(side: _borderSidePeach400);
    }
    return border300.copyWith(side: _borderSideGrey300);
  },
);

final _borderShape200 = MaterialStateProperty.resolveWith(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return border200;
    }
    if (states.contains(MaterialState.pressed)) {
      return border200;
    }
    if (states.contains(MaterialState.focused)) {
      return border200.copyWith(side: _borderSidePeach400);
    }
    return border200.copyWith(side: _borderSideGrey300);
  },
);

final _borderShape500 = MaterialStateProperty.resolveWith(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return border500;
    }
    if (states.contains(MaterialState.pressed)) {
      return border500;
    }
    if (states.contains(MaterialState.focused)) {
      return border500.copyWith(side: _borderSidePeach400);
    }
    return border500.copyWith(side: _borderSideGrey300);
  },
);

final _foregroundColorLightGrey = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return SurfaceColors.textSecondary;
    }
    return AbiliaColors.greyscale.shade000;
  },
);

final _foregroundColorDarkGrey = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return SurfaceColors.textSecondary;
    }
    return SurfaceColors.textPrimary;
  },
);

final _backgroundPrimary = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.greyscale.shade300;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.primary.shade700;
    }
    if (states.contains(MaterialState.hovered)) {
      return AbiliaColors.primary.shade600;
    }
    return AbiliaColors.primary.shade500;
  },
);

final _backgroundSecondary = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.greyscale.shade300;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.secondary.shade600;
    }
    if (states.contains(MaterialState.hovered)) {
      return AbiliaColors.secondary.shade500;
    }
    return AbiliaColors.secondary.shade400;
  },
);

final _backgroundLightGrey = MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.greyscale.shade300;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.greyscale.shade300;
    }
    if (states.contains(MaterialState.hovered)) {
      return AbiliaColors.greyscale;
    }
    return AbiliaColors.greyscale;
  },
);

final _backgroundLightGreyTransparent =
    MaterialStateProperty.resolveWith<Color>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return AbiliaColors.greyscale.shade300;
    }
    if (states.contains(MaterialState.pressed)) {
      return AbiliaColors.greyscale.shade300;
    }
    if (states.contains(MaterialState.hovered)) {
      return AbiliaColors.greyscale.shade200;
    }
    return AbiliaColors.transparent;
  },
);
