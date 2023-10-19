part of 'action_button_themes.dart';

class SeagullActionButtonTheme
    extends ThemeExtension<SeagullActionButtonTheme> {
  final double iconSpacing;
  final ButtonStyle buttonStyle;
  final SpinnerSize spinnerSize;

  const SeagullActionButtonTheme({
    required this.iconSpacing,
    required this.buttonStyle,
    required this.spinnerSize,
  });

  static final primary800 =
      SeagullActionButtonTheme.small(actionButtonPrimary800);
  static final primary900 =
      SeagullActionButtonTheme.medium(actionButtonPrimary900);
  static final primary1000 =
      SeagullActionButtonTheme.large(actionButtonPrimary1000);

  static final secondary800 =
      SeagullActionButtonTheme.small(actionButtonSecondary800);
  static final secondary900 =
      SeagullActionButtonTheme.medium(actionButtonSecondary900);
  static final secondary1000 =
      SeagullActionButtonTheme.large(actionButtonSecondary1000);

  static final tertiary800 =
      SeagullActionButtonTheme.small(actionButtonTertiary800);
  static final tertiary900 =
      SeagullActionButtonTheme.medium(actionButtonTertiary900);
  static final tertiary1000 =
      SeagullActionButtonTheme.large(actionButtonTertiary1000);

  static final tertiaryNoBorder800 =
      SeagullActionButtonTheme.small(actionButtonNoBorderTertiary800);
  static final tertiaryNoBorder900 =
      SeagullActionButtonTheme.medium(actionButtonNoBorderTertiary900);
  static final tertiaryNoBorder1000 =
      SeagullActionButtonTheme.large(actionButtonNoBorderTertiary1000);

  factory SeagullActionButtonTheme.small(ButtonStyle buttonStyle) =>
      SeagullActionButtonTheme(
        spinnerSize: SpinnerSize.small,
        iconSpacing: numerical100,
        buttonStyle: buttonStyle,
      );

  factory SeagullActionButtonTheme.medium(ButtonStyle buttonStyle) =>
      SeagullActionButtonTheme(
        spinnerSize: SpinnerSize.small,
        iconSpacing: numerical200,
        buttonStyle: buttonStyle,
      );

  factory SeagullActionButtonTheme.large(ButtonStyle buttonStyle) =>
      SeagullActionButtonTheme(
        spinnerSize: SpinnerSize.medium,
        iconSpacing: numerical200,
        buttonStyle: buttonStyle,
      );

  @override
  SeagullActionButtonTheme copyWith({
    double? iconSpacing,
    ButtonStyle? buttonStyle,
    SpinnerSize? spinnerSize,
  }) {
    return SeagullActionButtonTheme(
      iconSpacing: iconSpacing ?? this.iconSpacing,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      spinnerSize: spinnerSize ?? this.spinnerSize,
    );
  }

  @override
  SeagullActionButtonTheme lerp(SeagullActionButtonTheme? other, double t) {
    if (other is! SeagullActionButtonTheme) return this;
    return SeagullActionButtonTheme(
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t) ?? iconSpacing,
      buttonStyle:
          ButtonStyle.lerp(buttonStyle, other.buttonStyle, t) ?? buttonStyle,
      spinnerSize: other.spinnerSize,
    );
  }
}
