import 'package:flutter/material.dart';
import 'package:ui/styles/buttons/button_styles.dart';

part 'icon_button_theme.dart';

class SeagullIconButtonThemes extends ThemeExtension<SeagullIconButtonThemes> {
  final SeagullIconButtonTheme small;
  final SeagullIconButtonTheme noBorderSmall;
  final SeagullIconButtonTheme medium;
  final SeagullIconButtonTheme noBorderMedium;
  final SeagullIconButtonTheme large;
  final SeagullIconButtonTheme noBorderLarge;

  const SeagullIconButtonThemes({
    required this.small,
    required this.noBorderSmall,
    required this.medium,
    required this.noBorderMedium,
    required this.large,
    required this.noBorderLarge,
  });

  static final SeagullIconButtonThemes mobile = SeagullIconButtonThemes(
    small: SeagullIconButtonTheme.border800,
    noBorderSmall: SeagullIconButtonTheme.noBorder800,
    medium: SeagullIconButtonTheme.border900,
    noBorderMedium: SeagullIconButtonTheme.noBorder900,
    large: SeagullIconButtonTheme.border900,
    noBorderLarge: SeagullIconButtonTheme.noBorder900,
  );

  static final SeagullIconButtonThemes tablet = mobile;

  static final SeagullIconButtonThemes desktopSmall = mobile.copyWith(
    large: SeagullIconButtonTheme.border1000,
    noBorderLarge: SeagullIconButtonTheme.noBorder1000,
  );

  static final SeagullIconButtonThemes desktopLarge = desktopSmall;

  @override
  SeagullIconButtonThemes copyWith({
    SeagullIconButtonTheme? small,
    SeagullIconButtonTheme? noBorderSmall,
    SeagullIconButtonTheme? medium,
    SeagullIconButtonTheme? noBorderMedium,
    SeagullIconButtonTheme? large,
    SeagullIconButtonTheme? noBorderLarge,
  }) {
    return SeagullIconButtonThemes(
      small: small ?? this.small,
      noBorderSmall: noBorderSmall ?? this.noBorderSmall,
      medium: medium ?? this.medium,
      noBorderMedium: noBorderMedium ?? this.noBorderMedium,
      large: large ?? this.large,
      noBorderLarge: noBorderLarge ?? this.noBorderLarge,
    );
  }

  @override
  SeagullIconButtonThemes lerp(SeagullIconButtonThemes? other, double t) {
    if (other is! SeagullIconButtonThemes) return this;
    return SeagullIconButtonThemes(
      small: small.lerp(other.small, t),
      noBorderSmall: noBorderSmall.lerp(other.noBorderSmall, t),
      medium: medium.lerp(other.medium, t),
      noBorderMedium: noBorderMedium.lerp(other.noBorderMedium, t),
      large: large.lerp(other.large, t),
      noBorderLarge: noBorderLarge.lerp(other.noBorderLarge, t),
    );
  }
}
