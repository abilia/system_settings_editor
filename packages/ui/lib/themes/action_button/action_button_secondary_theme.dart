part of 'action_buttons_theme.dart';

class ActionButtonSecondaryTheme extends ActionButtonTheme {
  const ActionButtonSecondaryTheme({
    required super.iconSpacing,
    required super.buttonStyle,
  });

  static final small = ActionButtonTheme.small(actionButtonSecondarySmall);
  static final medium = ActionButtonTheme.medium(actionButtonSecondaryMedium);
}
