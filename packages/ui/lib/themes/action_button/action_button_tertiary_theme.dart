part of 'action_button_theme.dart';

class ActionButtonTertiaryTheme extends ActionButtonTheme {
  const ActionButtonTertiaryTheme({
    required super.iconSpacing,
    required super.buttonStyle,
  });

  static final small = ActionButtonTertiaryTheme(
    iconSpacing: numerical100,
    buttonStyle: actionButtonTertiary800,
  );

  static final medium = ActionButtonTertiaryTheme(
    iconSpacing: numerical200,
    buttonStyle: actionButtonTertiary900,
  );

  @override
  ActionButtonTertiaryTheme copyWith({
    double? iconSpacing,
    ButtonStyle? buttonStyle,
  }) {
    return ActionButtonTertiaryTheme(
      iconSpacing: iconSpacing ?? this.iconSpacing,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  @override
  ActionButtonTertiaryTheme lerp(ActionButtonTertiaryTheme? other, double t) {
    if (other is! ActionButtonTertiaryTheme) return this;
    return ActionButtonTertiaryTheme(
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t) ?? iconSpacing,
      buttonStyle:
          ButtonStyle.lerp(buttonStyle, other.buttonStyle, t) ?? buttonStyle,
    );
  }
}
