import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/src/colors.dart';
import 'package:ui/src/fonts.dart';
import 'package:ui/src/numericals.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/themes/abilia_text_style_themes.dart';

part 'combo_box_theme.dart';

class SeagullComboBoxThemes extends ThemeExtension<SeagullComboBoxThemes> {
  final SeagullComboBoxTheme medium;
  final SeagullComboBoxTheme large;

  const SeagullComboBoxThemes({
    required this.medium,
    required this.large,
  });

  static final SeagullComboBoxThemes mobile = SeagullComboBoxThemes(
    medium: SeagullComboBoxTheme.size700,
    large: SeagullComboBoxTheme.size700,
  );

  static final SeagullComboBoxThemes tablet = mobile;

  static final SeagullComboBoxThemes desktopSmall = mobile.copyWith(
    large: SeagullComboBoxTheme.size800,
  );

  static final SeagullComboBoxThemes desktopLarge = desktopSmall;

  @override
  SeagullComboBoxThemes copyWith({
    SeagullComboBoxTheme? medium,
    SeagullComboBoxTheme? large,
  }) {
    return SeagullComboBoxThemes(
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  SeagullComboBoxThemes lerp(SeagullComboBoxThemes? other, double t) {
    if (other is! SeagullComboBoxThemes) return this;
    return SeagullComboBoxThemes(
      medium: medium.lerp(other.medium, t),
      large: large.lerp(other.large, t),
    );
  }
}
