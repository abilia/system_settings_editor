part of 'action_button.dart';

class ActionButtonTertiary extends ActionButton {
  ActionButtonTertiary({
    required super.text,
    required super.onPressed,
    super.leadingIcon,
    super.trailingIcon,
    super.key,
  }) : super(
          themeBuilder: (context) => context.abiliaTheme.actionButtonTertiary,
        );
}
