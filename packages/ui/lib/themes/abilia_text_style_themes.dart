import 'package:flutter/material.dart';
import 'package:ui/src/fonts.dart';

extension TextStyleWithColor on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}

class AbiliaTextStyleThemes extends ThemeExtension<AbiliaTextStyleThemes> {
  final TextStyle primary125;
  final TextStyle primary225;
  final TextStyle primary250;
  final TextStyle primary300;
  final TextStyle primary350;
  final TextStyle primary400;
  final TextStyle primary425;
  final TextStyle primary450;
  final TextStyle primary525;
  final TextStyle primary600;
  final TextStyle primary725;
  final TextStyle primary950;

  const AbiliaTextStyleThemes({
    required this.primary125,
    required this.primary225,
    required this.primary250,
    required this.primary300,
    required this.primary350,
    required this.primary400,
    required this.primary425,
    required this.primary450,
    required this.primary525,
    required this.primary600,
    required this.primary725,
    required this.primary950,
  });

  static final AbiliaTextStyleThemes textStyles = AbiliaTextStyleThemes(
    primary125: AbiliaFonts.primary125,
    primary225: AbiliaFonts.primary225,
    primary250: AbiliaFonts.primary250,
    primary300: AbiliaFonts.primary300,
    primary350: AbiliaFonts.primary350,
    primary400: AbiliaFonts.primary400,
    primary425: AbiliaFonts.primary425,
    primary450: AbiliaFonts.primary450,
    primary525: AbiliaFonts.primary525,
    primary600: AbiliaFonts.primary600,
    primary725: AbiliaFonts.primary725,
    primary950: AbiliaFonts.primary950,
  );

  @override
  AbiliaTextStyleThemes copyWith({
    TextStyle? primary125,
    TextStyle? primary225,
    TextStyle? primary250,
    TextStyle? primary300,
    TextStyle? primary350,
    TextStyle? primary400,
    TextStyle? primary425,
    TextStyle? primary450,
    TextStyle? primary525,
    TextStyle? primary600,
    TextStyle? primary725,
    TextStyle? primary950,
  }) {
    return AbiliaTextStyleThemes(
      primary125: primary125 ?? this.primary125,
      primary225: primary225 ?? this.primary225,
      primary250: primary250 ?? this.primary250,
      primary300: primary300 ?? this.primary300,
      primary350: primary350 ?? this.primary350,
      primary400: primary400 ?? this.primary400,
      primary425: primary425 ?? this.primary425,
      primary450: primary450 ?? this.primary450,
      primary525: primary525 ?? this.primary525,
      primary600: primary600 ?? this.primary600,
      primary725: primary725 ?? this.primary725,
      primary950: primary950 ?? this.primary950,
    );
  }

  @override
  AbiliaTextStyleThemes lerp(AbiliaTextStyleThemes? other, double t) {
    if (other is! AbiliaTextStyleThemes) return this;
    return AbiliaTextStyleThemes(
      primary125: TextStyle.lerp(primary125, other.primary125, t) ?? primary125,
      primary225: TextStyle.lerp(primary225, other.primary225, t) ?? primary225,
      primary250: TextStyle.lerp(primary250, other.primary250, t) ?? primary250,
      primary300: TextStyle.lerp(primary300, other.primary300, t) ?? primary300,
      primary350: TextStyle.lerp(primary350, other.primary350, t) ?? primary350,
      primary400: TextStyle.lerp(primary400, other.primary400, t) ?? primary400,
      primary425: TextStyle.lerp(primary425, other.primary425, t) ?? primary425,
      primary450: TextStyle.lerp(primary450, other.primary450, t) ?? primary450,
      primary525: TextStyle.lerp(primary525, other.primary525, t) ?? primary525,
      primary600: TextStyle.lerp(primary600, other.primary600, t) ?? primary600,
      primary725: TextStyle.lerp(primary725, other.primary725, t) ?? primary725,
      primary950: TextStyle.lerp(primary950, other.primary950, t) ?? primary950,
    );
  }
}
