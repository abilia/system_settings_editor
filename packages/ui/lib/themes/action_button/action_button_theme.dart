part of 'action_buttons_theme.dart';

class ActionButtonTheme extends ThemeExtension<ActionButtonTheme> {
  final double iconSpacing;
  final ButtonStyle buttonStyle;

  const ActionButtonTheme({
    required this.iconSpacing,
    required this.buttonStyle,
  });

  factory ActionButtonTheme.small(ButtonStyle buttonStyle) => ActionButtonTheme(
        iconSpacing: numerical100,
        buttonStyle: buttonStyle,
      );

  factory ActionButtonTheme.medium(ButtonStyle buttonStyle) =>
      ActionButtonTheme(
        iconSpacing: numerical200,
        buttonStyle: buttonStyle,
      );

  factory ActionButtonTheme.large(ButtonStyle buttonStyle) => ActionButtonTheme(
        iconSpacing: numerical200,
        buttonStyle: buttonStyle,
      );

  @override
  ActionButtonTheme copyWith({
    double? iconSpacing,
    ButtonStyle? buttonStyle,
  }) {
    return ActionButtonTheme(
      iconSpacing: iconSpacing ?? this.iconSpacing,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  @override
  ActionButtonTheme lerp(ActionButtonTheme? other, double t) {
    if (other is! ActionButtonTheme) return this;
    return ActionButtonTheme(
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t) ?? iconSpacing,
      buttonStyle:
          ButtonStyle.lerp(buttonStyle, other.buttonStyle, t) ?? buttonStyle,
    );
  }
}
