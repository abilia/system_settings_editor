part of 'helper_box_themes.dart';

class SeagullHelperBoxTheme extends ThemeExtension<SeagullHelperBoxTheme> {
  final IconAndTextBoxTheme iconAndTextBoxTheme;

  const SeagullHelperBoxTheme({
    required this.iconAndTextBoxTheme,
  });

  static final size900 = SeagullHelperBoxTheme(
    iconAndTextBoxTheme: IconAndTextBoxTheme(
      textStyle: AbiliaFonts.primary300,
      padding: const EdgeInsets.all(numerical300),
      iconSize: numerical600,
      iconSpacing: numerical200,
      border: border200,
    ),
  );

  static final size1000 = size900.copyWith(
    iconAndTextBoxTheme: size900.iconAndTextBoxTheme.copyWith(
      textStyle: AbiliaFonts.primary400,
      padding: const EdgeInsets.all(numerical600),
      iconSize: numerical800,
    ),
  );

  @override
  SeagullHelperBoxTheme copyWith({
    IconAndTextBoxTheme? iconAndTextBoxTheme,
  }) {
    return SeagullHelperBoxTheme(
      iconAndTextBoxTheme: iconAndTextBoxTheme ?? this.iconAndTextBoxTheme,
    );
  }

  @override
  SeagullHelperBoxTheme lerp(SeagullHelperBoxTheme? other, double t) {
    if (other is! SeagullHelperBoxTheme) return this;
    return SeagullHelperBoxTheme(
      iconAndTextBoxTheme:
          iconAndTextBoxTheme.lerp(other.iconAndTextBoxTheme, t),
    );
  }
}
