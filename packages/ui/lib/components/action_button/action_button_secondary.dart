part of 'action_button.dart';

class ActionButtonSecondary extends ActionButton {
  ActionButtonSecondary({
    required super.text,
    required super.onPressed,
    super.leadingIcon,
    super.trailingIcon,
    super.key,
  }) : super(themeBuilder: (abiliaTheme) => abiliaTheme.actionButtonSecondary);
}
