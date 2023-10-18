import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/styles/buttons/button_styles.dart';
import 'package:ui/tokens/numericals.dart';

part 'action_button_theme.dart';

class SeagullActionButtonThemes
    extends ThemeExtension<SeagullActionButtonThemes> {
  final SeagullActionButtonTheme primarySmall;
  final SeagullActionButtonTheme secondarySmall;
  final SeagullActionButtonTheme tertiarySmall;
  final SeagullActionButtonTheme tertiaryNoBorderSmall;
  final SeagullActionButtonTheme primaryMedium;
  final SeagullActionButtonTheme secondaryMedium;
  final SeagullActionButtonTheme tertiaryMedium;
  final SeagullActionButtonTheme tertiaryNoBorderMedium;
  final SeagullActionButtonTheme primaryLarge;
  final SeagullActionButtonTheme secondaryLarge;
  final SeagullActionButtonTheme tertiaryLarge;
  final SeagullActionButtonTheme tertiaryNoBorderLarge;

  const SeagullActionButtonThemes({
    required this.primarySmall,
    required this.secondarySmall,
    required this.tertiarySmall,
    required this.tertiaryNoBorderSmall,
    required this.primaryMedium,
    required this.secondaryMedium,
    required this.tertiaryMedium,
    required this.tertiaryNoBorderMedium,
    required this.primaryLarge,
    required this.secondaryLarge,
    required this.tertiaryLarge,
    required this.tertiaryNoBorderLarge,
  });

  static final SeagullActionButtonThemes mobile = SeagullActionButtonThemes(
    primarySmall: SeagullActionButtonTheme.primary800,
    secondarySmall: SeagullActionButtonTheme.secondary800,
    tertiarySmall: SeagullActionButtonTheme.tertiary800,
    tertiaryNoBorderSmall: SeagullActionButtonTheme.tertiaryNoBorder800,
    primaryMedium: SeagullActionButtonTheme.primary900,
    secondaryMedium: SeagullActionButtonTheme.secondary900,
    tertiaryMedium: SeagullActionButtonTheme.tertiary900,
    tertiaryNoBorderMedium: SeagullActionButtonTheme.tertiaryNoBorder900,
    primaryLarge: SeagullActionButtonTheme.primary900,
    secondaryLarge: SeagullActionButtonTheme.secondary900,
    tertiaryLarge: SeagullActionButtonTheme.tertiary900,
    tertiaryNoBorderLarge: SeagullActionButtonTheme.tertiaryNoBorder900,
  );

  static final SeagullActionButtonThemes tablet = mobile;

  static final SeagullActionButtonThemes desktopSmall = mobile.copyWith(
    primaryLarge: SeagullActionButtonTheme.primary1000,
    secondaryLarge: SeagullActionButtonTheme.secondary1000,
    tertiaryLarge: SeagullActionButtonTheme.tertiary1000,
    tertiaryNoBorderLarge: SeagullActionButtonTheme.tertiaryNoBorder1000,
  );

  static final SeagullActionButtonThemes desktopLarge = desktopSmall;

  @override
  SeagullActionButtonThemes copyWith({
    SeagullActionButtonTheme? primarySmall,
    SeagullActionButtonTheme? secondarySmall,
    SeagullActionButtonTheme? tertiarySmall,
    SeagullActionButtonTheme? tertiaryNoBorderSmall,
    SeagullActionButtonTheme? primaryMedium,
    SeagullActionButtonTheme? secondaryMedium,
    SeagullActionButtonTheme? tertiaryMedium,
    SeagullActionButtonTheme? tertiaryNoBorderMedium,
    SeagullActionButtonTheme? primaryLarge,
    SeagullActionButtonTheme? secondaryLarge,
    SeagullActionButtonTheme? tertiaryLarge,
    SeagullActionButtonTheme? tertiaryNoBorderLarge,
  }) {
    return SeagullActionButtonThemes(
      primarySmall: primarySmall ?? this.primarySmall,
      secondarySmall: secondarySmall ?? this.secondarySmall,
      tertiarySmall: tertiarySmall ?? this.tertiarySmall,
      tertiaryNoBorderSmall:
          tertiaryNoBorderSmall ?? this.tertiaryNoBorderSmall,
      primaryMedium: primaryMedium ?? this.primaryMedium,
      secondaryMedium: secondaryMedium ?? this.secondaryMedium,
      tertiaryMedium: tertiaryMedium ?? this.tertiaryMedium,
      tertiaryNoBorderMedium:
          tertiaryNoBorderMedium ?? this.tertiaryNoBorderMedium,
      primaryLarge: primaryLarge ?? this.primaryLarge,
      secondaryLarge: secondaryLarge ?? this.secondaryLarge,
      tertiaryLarge: tertiaryLarge ?? this.tertiaryLarge,
      tertiaryNoBorderLarge:
          tertiaryNoBorderLarge ?? this.tertiaryNoBorderLarge,
    );
  }

  @override
  SeagullActionButtonThemes lerp(SeagullActionButtonThemes? other, double t) {
    if (other is! SeagullActionButtonThemes) return this;
    return SeagullActionButtonThemes(
      primarySmall: primarySmall.lerp(other.primarySmall, t),
      secondarySmall: secondarySmall.lerp(other.secondarySmall, t),
      tertiarySmall: tertiarySmall.lerp(other.tertiarySmall, t),
      tertiaryNoBorderSmall:
          tertiaryNoBorderSmall.lerp(other.tertiaryNoBorderSmall, t),
      primaryMedium: primaryMedium.lerp(other.primaryMedium, t),
      secondaryMedium: secondaryMedium.lerp(other.secondaryMedium, t),
      tertiaryMedium: tertiaryMedium.lerp(other.tertiaryMedium, t),
      tertiaryNoBorderMedium:
          tertiaryNoBorderMedium.lerp(other.tertiaryNoBorderMedium, t),
      primaryLarge: primaryLarge.lerp(other.primaryLarge, t),
      secondaryLarge: secondaryLarge.lerp(other.secondaryLarge, t),
      tertiaryLarge: tertiaryLarge.lerp(other.tertiaryLarge, t),
      tertiaryNoBorderLarge:
          tertiaryNoBorderLarge.lerp(other.tertiaryNoBorderLarge, t),
    );
  }
}
