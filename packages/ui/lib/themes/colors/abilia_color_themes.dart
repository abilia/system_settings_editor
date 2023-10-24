import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/themes/colors/surface_color_theme.dart';

class AbiliaColorThemes extends ThemeExtension<AbiliaColorThemes> {
  final AbiliaMaterialColor primary;
  final AbiliaMaterialColor secondary;
  final AbiliaMaterialColor yellow;
  final AbiliaMaterialColor peach;
  final AbiliaMaterialColor greyscale;
  final SurfaceColorTheme surface;

  const AbiliaColorThemes({
    required this.primary,
    required this.secondary,
    required this.yellow,
    required this.peach,
    required this.greyscale,
    required this.surface,
  });

  static final AbiliaColorThemes colors = AbiliaColorThemes(
    primary: AbiliaColors.primary,
    secondary: AbiliaColors.secondary,
    yellow: AbiliaColors.yellow,
    peach: AbiliaColors.peach,
    greyscale: AbiliaColors.greyscale,
    surface: SurfaceColorTheme.colors,
  );

  @override
  AbiliaColorThemes copyWith({
    AbiliaMaterialColor? primary,
    AbiliaMaterialColor? secondary,
    AbiliaMaterialColor? yellow,
    AbiliaMaterialColor? peach,
    AbiliaMaterialColor? greyscale,
    SurfaceColorTheme? surface,
  }) {
    return AbiliaColorThemes(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      yellow: yellow ?? this.yellow,
      peach: peach ?? this.peach,
      greyscale: greyscale ?? this.greyscale,
      surface: surface ?? this.surface,
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
      surface: surface.lerp(other.surface, t),
    );
  }
}
