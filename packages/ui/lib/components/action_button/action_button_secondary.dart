part of 'action_button.dart';

class ActionButtonSecondary extends ActionButton {
  ActionButtonSecondary({
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
                return actionButtonsTheme.secondarySmall;
              case ActionButtonSize.medium:
                return actionButtonsTheme.secondaryMedium;
              case ActionButtonSize.large:
                return actionButtonsTheme.secondaryLarge;
            }
          },
        );
}
