import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';

class SurfaceColorTheme extends ThemeExtension<SurfaceColorTheme> {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color textInverted;
  final Color textActive;
  final Color textSecondary;
  final Color textLabel;
  final Color textPrimary;
  final Color subdued;
  final Color active;
  final Color selected;
  final Color hoverSubdued;
  final Color hover;
  final Color positiveSelected;
  final Color borderPrimary;
  final Color borderActive;
  final Color borderFocus;

  const SurfaceColorTheme({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.textInverted,
    required this.textActive,
    required this.textSecondary,
    required this.textLabel,
    required this.textPrimary,
    required this.subdued,
    required this.active,
    required this.selected,
    required this.hoverSubdued,
    required this.hover,
    required this.positiveSelected,
    required this.borderPrimary,
    required this.borderActive,
    required this.borderFocus,
  });

  static final SurfaceColorTheme colors = SurfaceColorTheme(
    primary: SurfaceColors.primary,
    secondary: SurfaceColors.secondary,
    tertiary: SurfaceColors.tertiary,
    textInverted: SurfaceColors.textInverted,
    textActive: SurfaceColors.textActive,
    textSecondary: SurfaceColors.textSecondary,
    textLabel: SurfaceColors.textLabel,
    textPrimary: SurfaceColors.textPrimary,
    subdued: SurfaceColors.subdued,
    active: SurfaceColors.active,
    selected: SurfaceColors.selected,
    hoverSubdued: SurfaceColors.hoverSubdued,
    hover: SurfaceColors.hover,
    positiveSelected: SurfaceColors.positiveSelected,
    borderPrimary: SurfaceColors.borderPrimary,
    borderActive: SurfaceColors.borderActive,
    borderFocus: SurfaceColors.borderFocus,
  );

  @override
  SurfaceColorTheme copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? textInverted,
    Color? textActive,
    Color? textSecondary,
    Color? textLabel,
    Color? textPrimary,
    Color? subdued,
    Color? active,
    Color? selected,
    Color? hoverSubdued,
    Color? hover,
    Color? positiveSelected,
    Color? borderPrimary,
    Color? borderActive,
    Color? borderFocus,
  }) {
    return SurfaceColorTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      textInverted: textInverted ?? this.textInverted,
      textActive: textActive ?? this.textActive,
      textSecondary: textSecondary ?? this.textSecondary,
      textLabel: textLabel ?? this.textLabel,
      textPrimary: textPrimary ?? this.textPrimary,
      subdued: subdued ?? this.subdued,
      active: active ?? this.active,
      selected: selected ?? this.selected,
      hoverSubdued: hoverSubdued ?? this.hoverSubdued,
      hover: hover ?? this.hover,
      positiveSelected: positiveSelected ?? this.positiveSelected,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderActive: borderActive ?? this.borderActive,
      borderFocus: borderFocus ?? this.borderFocus,
    );
  }

  @override
  SurfaceColorTheme lerp(SurfaceColorTheme? other, double t) {
    if (other is! SurfaceColorTheme) return this;
    return SurfaceColorTheme(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      tertiary: Color.lerp(tertiary, other.tertiary, t) ?? tertiary,
      textInverted:
          Color.lerp(textInverted, other.textInverted, t) ?? textInverted,
      textActive: Color.lerp(textActive, other.textActive, t) ?? textActive,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textLabel: Color.lerp(textLabel, other.textLabel, t) ?? textLabel,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      subdued: Color.lerp(subdued, other.subdued, t) ?? subdued,
      active: Color.lerp(active, other.active, t) ?? active,
      selected: Color.lerp(selected, other.selected, t) ?? selected,
      hoverSubdued:
          Color.lerp(hoverSubdued, other.hoverSubdued, t) ?? hoverSubdued,
      hover: Color.lerp(hover, other.hover, t) ?? hover,
      positiveSelected:
          Color.lerp(positiveSelected, other.positiveSelected, t) ??
              positiveSelected,
      borderPrimary:
          Color.lerp(borderPrimary, other.borderPrimary, t) ?? borderPrimary,
      borderActive:
          Color.lerp(borderActive, other.borderActive, t) ?? borderActive,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t) ?? borderFocus,
    );
  }
}
