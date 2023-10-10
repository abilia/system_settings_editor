import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/numericals.dart';

enum ActionButtonStyle {
  primary,
  secondary,
  tertiary,
  tertiarySmall;

  bool get isSmall => this == ActionButtonStyle.tertiarySmall;

  ButtonStyle get style {
    switch (this) {
      case ActionButtonStyle.primary:
        return actionButtonPrimary900;
      case ActionButtonStyle.secondary:
        return actionButtonSecondary900;
      case ActionButtonStyle.tertiary:
        return actionButtonTertiary900;
      case ActionButtonStyle.tertiarySmall:
        return actionButtonTertiary800;
    }
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final ActionButtonStyle actionButtonStyle;

  const ActionButton({
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.actionButtonStyle = ActionButtonStyle.primary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = actionButtonStyle.isSmall ? numerical100 : numerical200;
    final leadingIcon = this.leadingIcon;
    final trailingIcon = this.trailingIcon;
    return TextButton(
      style: actionButtonStyle.style,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon),
            SizedBox(width: spacing),
          ],
          Flexible(
            child: Text(
              text,
              softWrap: true,
              maxLines: 1,
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: spacing),
            Icon(trailingIcon),
          ],
        ],
      ),
    );
  }
}
