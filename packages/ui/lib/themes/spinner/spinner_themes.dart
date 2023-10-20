import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/src/numericals.dart';

part 'spinner_theme.dart';

class SeagullSpinnerThemes extends ThemeExtension<SeagullSpinnerThemes> {
  final SeagullSpinnerTheme small;
  final SeagullSpinnerTheme medium;

  const SeagullSpinnerThemes({
    required this.small,
    required this.medium,
  });

  static const SeagullSpinnerThemes spinners = SeagullSpinnerThemes(
    small: SeagullSpinnerTheme.small,
    medium: SeagullSpinnerTheme.medium,
  );

  @override
  SeagullSpinnerThemes copyWith({
    SeagullSpinnerTheme? medium,
    SeagullSpinnerTheme? small,
  }) {
    return SeagullSpinnerThemes(
      medium: medium ?? this.medium,
      small: small ?? this.small,
    );
  }

  @override
  SeagullSpinnerThemes lerp(SeagullSpinnerThemes? other, double t) {
    if (other is! SeagullSpinnerThemes) return this;
    return SeagullSpinnerThemes(
      medium: medium.lerp(other.medium, t),
      small: small.lerp(other.small, t),
    );
  }
}
