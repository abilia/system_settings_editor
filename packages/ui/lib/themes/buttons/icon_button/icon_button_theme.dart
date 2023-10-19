part of 'icon_button_themes.dart';

class SeagullIconButtonTheme extends ThemeExtension<SeagullIconButtonTheme> {
  final ButtonStyle buttonStyle;

  const SeagullIconButtonTheme({
    required this.buttonStyle,
  });

  static final border800 = SeagullIconButtonTheme(buttonStyle: iconButton800);

  static final border900 = SeagullIconButtonTheme(buttonStyle: iconButton900);

  static final border1000 = SeagullIconButtonTheme(buttonStyle: iconButton1000);

  static final noBorder800 =
      SeagullIconButtonTheme(buttonStyle: iconButtonNoBorder800);

  static final noBorder900 =
      SeagullIconButtonTheme(buttonStyle: iconButtonNoBorder900);

  static final noBorder1000 =
      SeagullIconButtonTheme(buttonStyle: iconButtonNoBorder1000);

  @override
  SeagullIconButtonTheme copyWith({
    double? iconSpacing,
    ButtonStyle? buttonStyle,
  }) {
    return SeagullIconButtonTheme(
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  @override
  SeagullIconButtonTheme lerp(SeagullIconButtonTheme? other, double t) {
    if (other is! SeagullIconButtonTheme) return this;
    return SeagullIconButtonTheme(
      buttonStyle:
          ButtonStyle.lerp(buttonStyle, other.buttonStyle, t) ?? buttonStyle,
    );
  }
}
