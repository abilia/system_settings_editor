import 'package:flutter/material.dart';
import 'package:ui/components/base_themes/icon_and_text_box_theme.dart';
import 'package:ui/src/fonts.dart';
import 'package:ui/src/numericals.dart';
import 'package:ui/styles/borders.dart';

part 'tag_theme.dart';

class SeagullTagThemes extends ThemeExtension<SeagullTagThemes> {
  final SeagullTagTheme size600;
  final SeagullTagTheme size700;

  const SeagullTagThemes({
    required this.size600,
    required this.size700,
  });

  static final SeagullTagThemes mobile = SeagullTagThemes(
    size600: SeagullTagTheme.primary600,
    size700: SeagullTagTheme.primary700,
  );

  static final SeagullTagThemes tablet = mobile;

  static final SeagullTagThemes desktopSmall = tablet;

  static final SeagullTagThemes desktopLarge = desktopSmall;

  @override
  SeagullTagThemes copyWith({
    SeagullTagTheme? size600,
    SeagullTagTheme? size700,
  }) {
    return SeagullTagThemes(
      size600: size600 ?? this.size600,
      size700: size700 ?? this.size700,
    );
  }

  @override
  SeagullTagThemes lerp(SeagullTagThemes? other, double t) {
    if (other is! SeagullTagThemes) return this;
    return SeagullTagThemes(
      size600: size600.lerp(other.size600, t),
      size700: size700.lerp(other.size700, t),
    );
  }
}
