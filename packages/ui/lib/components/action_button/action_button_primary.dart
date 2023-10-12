part of 'action_button.dart';

class ActionButtonPrimary extends ActionButton {
  ActionButtonPrimary({
    required super.text,
    required super.onPressed,
    required super.size,
    super.leadingIcon,
    super.trailingIcon,
    super.key,
  }) : super(
          themeBuilder: (actionButtonsTheme) {
            switch (size) {
              case ActionButtonSize.small:
                return actionButtonsTheme.primarySmall;
              case ActionButtonSize.medium:
                return actionButtonsTheme.primaryMedium;
              case ActionButtonSize.large:
                return actionButtonsTheme.primaryLarge;
            }
          },
        );
}
