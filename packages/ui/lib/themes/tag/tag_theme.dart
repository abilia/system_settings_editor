part of 'tag_themes.dart';

class SeagullTagTheme extends ThemeExtension<SeagullTagTheme> {
  final IconAndTextBoxTheme iconAndTextBoxTheme;

  const SeagullTagTheme({
    required this.iconAndTextBoxTheme,
  });

  static final size700 = SeagullTagTheme(
    iconAndTextBoxTheme: IconAndTextBoxTheme(
      textStyle: AbiliaFonts.primary425,
      padding: const EdgeInsets.symmetric(
        horizontal: numerical300,
        vertical: numerical200,
      ),
      iconSize: numerical600,
      iconSpacing: numerical200,
      border: roundedRectangleBorder600,
    ),
  );

  static final size600 = size700.copyWith(
    iconAndTextBoxTheme: size700.iconAndTextBoxTheme.copyWith(
      padding: const EdgeInsets.symmetric(
        horizontal: numerical300,
        vertical: numerical100,
      ),
    ),
  );

  @override
  SeagullTagTheme copyWith({
    IconAndTextBoxTheme? iconAndTextBoxTheme,
  }) {
    return SeagullTagTheme(
      iconAndTextBoxTheme: iconAndTextBoxTheme ?? this.iconAndTextBoxTheme,
    );
  }

  @override
  SeagullTagTheme lerp(SeagullTagTheme? other, double t) {
    if (other is! SeagullTagTheme) return this;
    return SeagullTagTheme(
      iconAndTextBoxTheme:
          iconAndTextBoxTheme.lerp(other.iconAndTextBoxTheme, t),
    );
  }
}
