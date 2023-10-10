part of 'action_button.dart';

class ActionButtonPrimary extends ActionButton {
  ActionButtonPrimary({
    required super.text,
    required super.onPressed,
    super.leadingIcon,
    super.trailingIcon,
    super.key,
  }) : super(themeBuilder: (abiliaTheme) => abiliaTheme.actionButtonPrimary);
}
