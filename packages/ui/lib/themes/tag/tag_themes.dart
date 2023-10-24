import 'package:flutter/material.dart';
import 'package:ui/src/styles/borders.dart';
import 'package:ui/src/tokens/fonts.dart';
import 'package:ui/src/tokens/numericals.dart';
import 'package:ui/themes/base_themes/icon_and_text_box_theme.dart';

part 'tag_theme.dart';

class SeagullTagThemes extends ThemeExtension<SeagullTagThemes> {
  final SeagullTagTheme size600;
  final SeagullTagTheme size700;

  const SeagullTagThemes({
    required this.size600,
    required this.size700,
  });

  static final SeagullTagThemes tags = SeagullTagThemes(
    size600: SeagullTagTheme.size600,
    size700: SeagullTagTheme.size700,
  );

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
