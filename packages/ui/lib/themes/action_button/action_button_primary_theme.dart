part of 'action_button_theme.dart';

class ActionButtonPrimaryTheme extends ActionButtonTheme {
  const ActionButtonPrimaryTheme({
    required super.iconSpacing,
    required super.buttonStyle,
  });

  static final small = ActionButtonPrimaryTheme(
    iconSpacing: numerical100,
    buttonStyle: actionButtonPrimary900, // placeholder value
  );
  static final medium = ActionButtonPrimaryTheme(
    iconSpacing: numerical200,
    buttonStyle: actionButtonPrimary900,
  );

  @override
  ActionButtonPrimaryTheme copyWith({
    double? iconSpacing,
    ButtonStyle? buttonStyle,
  }) {
    return ActionButtonPrimaryTheme(
      iconSpacing: iconSpacing ?? this.iconSpacing,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  @override
  ActionButtonPrimaryTheme lerp(ActionButtonPrimaryTheme? other, double t) {
    if (other is! ActionButtonPrimaryTheme) return this;
    return ActionButtonPrimaryTheme(
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t) ?? iconSpacing,
      buttonStyle:
          ButtonStyle.lerp(buttonStyle, other.buttonStyle, t) ?? buttonStyle,
    );
  }
}
