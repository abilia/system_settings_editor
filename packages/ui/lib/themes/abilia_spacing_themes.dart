import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/src/numericals.dart';

class AbiliaSpacingThemes extends ThemeExtension<AbiliaSpacingThemes> {
  final double spacing100;
  final double spacing200;
  final double spacing300;
  final double spacing400;
  final double spacing600;
  final double spacing800;
  final double spacing1000;

  const AbiliaSpacingThemes({
    required this.spacing100,
    required this.spacing200,
    required this.spacing300,
    required this.spacing400,
    required this.spacing600,
    required this.spacing800,
    required this.spacing1000,
  });

  static const AbiliaSpacingThemes spacings = AbiliaSpacingThemes(
    spacing100: numerical100,
    spacing200: numerical200,
    spacing300: numerical300,
    spacing400: numerical400,
    spacing600: numerical600,
    spacing800: numerical800,
    spacing1000: numerical1000,
  );

  @override
  AbiliaSpacingThemes copyWith({
    double? spacing100,
    double? spacing200,
    double? spacing300,
    double? spacing400,
    double? spacing600,
    double? spacing800,
    double? spacing1000,
  }) {
    return AbiliaSpacingThemes(
      spacing100: spacing100 ?? this.spacing100,
      spacing200: spacing200 ?? this.spacing200,
      spacing300: spacing300 ?? this.spacing300,
      spacing400: spacing400 ?? this.spacing400,
      spacing600: spacing600 ?? this.spacing600,
      spacing800: spacing800 ?? this.spacing800,
      spacing1000: spacing1000 ?? this.spacing1000,
    );
  }

  @override
  AbiliaSpacingThemes lerp(AbiliaSpacingThemes? other, double t) {
    if (other is! AbiliaSpacingThemes) return this;
    return AbiliaSpacingThemes(
      spacing100: lerpDouble(spacing100, other.spacing100, t) ?? spacing100,
      spacing200: lerpDouble(spacing200, other.spacing200, t) ?? spacing200,
      spacing300: lerpDouble(spacing300, other.spacing300, t) ?? spacing300,
      spacing400: lerpDouble(spacing400, other.spacing400, t) ?? spacing400,
      spacing600: lerpDouble(spacing600, other.spacing600, t) ?? spacing600,
      spacing800: lerpDouble(spacing800, other.spacing800, t) ?? spacing800,
      spacing1000: lerpDouble(spacing1000, other.spacing1000, t) ?? spacing1000,
    );
  }
}
