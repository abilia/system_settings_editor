part of 'action_buttons_theme.dart';

class ActionButtonTertiaryTheme extends ActionButtonTheme {
  const ActionButtonTertiaryTheme({
    required super.iconSpacing,
    required super.buttonStyle,
  });

  static final small = ActionButtonTheme.small(actionButtonTertiarySmall);
  static final medium = ActionButtonTheme.medium(actionButtonTertiaryMedium);
}
