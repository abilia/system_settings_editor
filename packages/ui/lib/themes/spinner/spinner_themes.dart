import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/src/tokens/numericals.dart';

part 'spinner_theme.dart';

class SeagullSpinnerThemes extends ThemeExtension<SeagullSpinnerThemes> {
  final SeagullSpinnerTheme large;
  final SeagullSpinnerTheme medium;

  const SeagullSpinnerThemes({
    required this.large,
    required this.medium,
  });

  static const SeagullSpinnerThemes spinners = SeagullSpinnerThemes(
    large: SeagullSpinnerTheme.large,
    medium: SeagullSpinnerTheme.medium,
  );

  @override
  SeagullSpinnerThemes copyWith({
    SeagullSpinnerTheme? medium,
    SeagullSpinnerTheme? large,
  }) {
    return SeagullSpinnerThemes(
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  SeagullSpinnerThemes lerp(SeagullSpinnerThemes? other, double t) {
    if (other is! SeagullSpinnerThemes) return this;
    return SeagullSpinnerThemes(
      medium: medium.lerp(other.medium, t),
      large: large.lerp(other.large, t),
    );
  }
}
