part of 'action_button_theme.dart';

class ActionButtonSecondaryTheme extends ActionButtonTheme {
  const ActionButtonSecondaryTheme({
    required super.iconSpacing,
    required super.buttonStyle,
  });

  static final small = ActionButtonSecondaryTheme(
    iconSpacing: numerical100,
    buttonStyle: actionButtonSecondary900, // placeholder value
  );

  static final medium = ActionButtonSecondaryTheme(
    iconSpacing: numerical200,
    buttonStyle: actionButtonSecondary900,
  );

  @override
  ActionButtonSecondaryTheme copyWith({
    double? iconSpacing,
    ButtonStyle? buttonStyle,
  }) {
    return ActionButtonSecondaryTheme(
      iconSpacing: iconSpacing ?? this.iconSpacing,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  @override
  ActionButtonSecondaryTheme lerp(ActionButtonSecondaryTheme? other, double t) {
    if (other is! ActionButtonSecondaryTheme) return this;
    return ActionButtonSecondaryTheme(
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t) ?? iconSpacing,
      buttonStyle:
          ButtonStyle.lerp(buttonStyle, other.buttonStyle, t) ?? buttonStyle,
    );
  }
}
