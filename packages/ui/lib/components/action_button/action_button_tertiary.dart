part of 'action_button.dart';

class ActionButtonTertiary extends ActionButton {
  ActionButtonTertiary({
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
                return actionButtonsTheme.tertiarySmall;
              case ActionButtonSize.medium:
                return actionButtonsTheme.tertiaryMedium;
              case ActionButtonSize.large:
                return actionButtonsTheme.tertiaryLarge;
            }
          },
        );
}
