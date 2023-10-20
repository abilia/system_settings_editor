import 'package:flutter/material.dart';
import 'package:ui/styles/borders.dart';
import 'package:ui/themes/base_themes/icon_and_text_box_theme.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

part 'helper_box_theme.dart';

class SeagullHelperBoxThemes extends ThemeExtension<SeagullHelperBoxThemes> {
  final SeagullHelperBoxTheme medium;
  final SeagullHelperBoxTheme large;

  const SeagullHelperBoxThemes({
    required this.medium,
    required this.large,
  });

  static final SeagullHelperBoxThemes mobile = SeagullHelperBoxThemes(
    medium: SeagullHelperBoxTheme.primary900,
    large: SeagullHelperBoxTheme.primary900,
  );

  static final SeagullHelperBoxThemes tablet = mobile;

  static final SeagullHelperBoxThemes desktopSmall = mobile.copyWith(
    large: SeagullHelperBoxTheme.primary1000,
  );

  static final SeagullHelperBoxThemes desktopLarge = desktopSmall;

  @override
  SeagullHelperBoxThemes copyWith({
    SeagullHelperBoxTheme? medium,
    SeagullHelperBoxTheme? large,
  }) {
    return SeagullHelperBoxThemes(
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  SeagullHelperBoxThemes lerp(SeagullHelperBoxThemes? other, double t) {
    if (other is! SeagullHelperBoxThemes) return this;
    return SeagullHelperBoxThemes(
      medium: medium.lerp(other.medium, t),
      large: large.lerp(other.large, t),
    );
  }
}
