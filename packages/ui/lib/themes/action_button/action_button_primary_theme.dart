part of 'action_buttons_theme.dart';

class ActionButtonPrimaryTheme extends ActionButtonTheme {
  const ActionButtonPrimaryTheme({
    required super.iconSpacing,
    required super.buttonStyle,
  });

  static final small = ActionButtonTheme.small(actionButtonPrimarySmall);
  static final medium = ActionButtonTheme.medium(actionButtonPrimaryMedium);
}
