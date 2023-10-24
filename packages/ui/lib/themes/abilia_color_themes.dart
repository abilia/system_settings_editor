import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';

class AbiliaColorThemes extends ThemeExtension<AbiliaColorThemes> {
  final AbiliaMaterialColor primary;
  final AbiliaMaterialColor secondary;
  final AbiliaMaterialColor yellow;
  final AbiliaMaterialColor peach;
  final AbiliaMaterialColor greyscale;

  const AbiliaColorThemes({
    required this.primary,
    required this.secondary,
    required this.yellow,
    required this.peach,
    required this.greyscale,
  });

  static const AbiliaColorThemes colors = AbiliaColorThemes(
    primary: AbiliaColors.primary,
    secondary: AbiliaColors.secondary,
    yellow: AbiliaColors.yellow,
    peach: AbiliaColors.peach,
    greyscale: AbiliaColors.greyscale,
  );

  @override
  AbiliaColorThemes copyWith({
    AbiliaMaterialColor? primary,
    AbiliaMaterialColor? secondary,
    AbiliaMaterialColor? yellow,
    AbiliaMaterialColor? peach,
    AbiliaMaterialColor? greyscale,
  }) {
    return AbiliaColorThemes(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      yellow: yellow ?? this.yellow,
      peach: peach ?? this.peach,
      greyscale: greyscale ?? this.greyscale,
    );
  }

  @override
  AbiliaColorThemes lerp(AbiliaColorThemes? other, double t) {
    if (other is! AbiliaColorThemes) return this;
    return AbiliaColorThemes(
      primary: other.primary,
      secondary: other.secondary,
      yellow: other.yellow,
      peach: other.peach,
      greyscale: other.greyscale,
    );
  }
}
