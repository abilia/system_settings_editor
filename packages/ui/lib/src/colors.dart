import 'package:flutter/material.dart';

class AbiliaMaterialColor extends MaterialColor {
  const AbiliaMaterialColor(super.primary, super.swatch);

  Color get shade000 => this[0]!;

  Color get shade1000 => this[1000]!;
}

class AbiliaColors {
  static const transparent = Color(0x00000000);

  static const int _peach100 = 0xFFFFD8CC;
  static const AbiliaMaterialColor peach = AbiliaMaterialColor(
    _peach100,
    <int, Color>{
      100: Color(_peach100),
      200: Color(0xFFFD9F81),
      300: Color(0xFFF97B53),
      400: Color(0xFFF05828),
      500: Color(0xFFBD390F),
      600: Color(0xFFFF250D),
    },
  );

  static const int _yellow100 = 0xFFFFF0A4;
  static const AbiliaMaterialColor yellow =
      AbiliaMaterialColor(_yellow100, <int, Color>{
    100: Color(_yellow100),
    200: Color(0xFFFFEA7B),
    300: Color(0xFFFFE146),
    400: Color(0xFFF8D51F),
    500: Color(0xFFF1CB00),
  });

  static const int _greyscale100 = 0xFFF2F3F7;
  static const AbiliaMaterialColor greyscale =
      AbiliaMaterialColor(_greyscale100, <int, Color>{
    0: Color(0xFFFFFFFF),
    50: Color(0xFFF9F9FB),
    100: Color(_greyscale100),
    200: Color(0xFFE8E9ED),
    300: Color(0xFFD9DADE),
    400: Color(0xFFC8C9CC),
    500: Color(0xFFBBBCBF),
    600: Color(0xFF646466),
    700: Color(0xFF575859),
    800: Color(0xFF4B4B4D),
    900: Color(0xFF252626),
    1000: Color(0xFF111212),
  });

  static const _primary100 = 0xFFF2F3FC;
  static const AbiliaMaterialColor primary =
      AbiliaMaterialColor(_primary100, <int, Color>{
    100: Color(_primary100),
    200: Color(0xFFD5D8F6),
    300: Color(0xFFC9CCF3),
    400: Color(0xFFB4B9EE),
    500: Color(0xFF4E5AD9),
    600: Color(0xFF454FBF),
    700: Color(0xFF3C45A6),
  });

  static const _secondary100 = 0xFFD9F9F1;
  static const AbiliaMaterialColor secondary =
      AbiliaMaterialColor(_secondary100, <int, Color>{
    100: Color(_secondary100),
    200: Color(0xFFC5F0E6),
    300: Color(0xFFB6E5DA),
    400: Color(0xFF027B5E),
    500: Color(0xFF027B5E),
    600: Color(0xFF016C53),
    700: Color(0xFF005F48),
  });
}

class SurfaceColors {
  static final primary = AbiliaColors.greyscale.shade000;
  static final secondary = AbiliaColors.greyscale.shade50;
  static final tertiary = AbiliaColors.greyscale.shade100;
  static final textInverted = AbiliaColors.greyscale.shade50;
  static final textActive = AbiliaColors.primary.shade500;
  static final textSecondary = AbiliaColors.greyscale.shade700;
  static final textLabel = AbiliaColors.greyscale.shade700;
  static final textPrimary = AbiliaColors.greyscale.shade900;
  static final subdued = AbiliaColors.greyscale.shade200;
  static final active = AbiliaColors.primary.shade200;
  static final selected = AbiliaColors.primary.shade100;
  static final hoverSubdued = AbiliaColors.primary.shade200;
  static final hover = AbiliaColors.primary.shade100;
}
