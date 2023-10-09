import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/numericals.dart';

enum ActionButtonStyle {
  primary,
  secondary,
  tertiary;

  ButtonStyle get style {
    switch (this) {
      case ActionButtonStyle.primary:
        return actionButtonPrimary900;
      case ActionButtonStyle.secondary:
        return actionButtonSecondary900;
      case ActionButtonStyle.tertiary:
        return actionButtonTertiary900;
    }
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final ButtonStyle _style;

  ActionButton({
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    ActionButtonStyle actionButtonStyle = ActionButtonStyle.primary,
    super.key,
  }) : _style = actionButtonStyle.style;

  @override
  Widget build(BuildContext context) {
    const spacing = numerical200;
    final leadingIcon = this.leadingIcon;
    final trailingIcon = this.trailingIcon;
    return TextButton(
      style: _style,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: spacing),
              child: Icon(leadingIcon),
            ),
          Flexible(
            child: Text(
              text,
              softWrap: true,
              maxLines: 1,
            ),
          ),
          if (trailingIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: spacing),
              child: Icon(trailingIcon),
            ),
        ],
      ),
    );
  }
}
