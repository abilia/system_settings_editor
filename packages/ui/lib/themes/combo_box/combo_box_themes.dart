import 'package:flutter/material.dart';
import 'package:ui/src/extensions/text_style_extensions.dart';
import 'package:ui/src/styles/borders.dart';
import 'package:ui/src/styles/box_decorations.dart';
import 'package:ui/src/themes/icon_themes.dart';
import 'package:ui/src/themes/input_decoration_themes.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/fonts.dart';
import 'package:ui/src/tokens/numericals.dart';

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
