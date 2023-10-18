import 'package:flutter/material.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/buttons/action_button/action_button_themes.dart';

enum ActionButtonType {
  primary,
  secondary,
  tertiary,
  tertiaryNoBorder,
}

class SeagullActionButton extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final ButtonSize size;

  const SeagullActionButton({
    required this.type,
    required this.text,
    required this.size,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final leadingIcon = this.leadingIcon;
    final trailingIcon = this.trailingIcon;
    final actionButtonTheme = _getTheme(context);
    return FilledButton(
      style: actionButtonTheme.buttonStyle,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon),
            SizedBox(width: actionButtonTheme.iconSpacing),
          ],
          Flexible(
            child: Text(
              text,
              softWrap: true,
              maxLines: 1,
            ),
          ),
          if (trailingIcon != null) ...[
            SizedBox(width: actionButtonTheme.iconSpacing),
            Icon(trailingIcon),
          ],
        ],
      ),
    );
  }

  SeagullActionButtonTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (type) {
      case ActionButtonType.primary:
        switch (size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.primarySmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.primaryMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.primaryLarge;
        }
      case ActionButtonType.secondary:
        switch (size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.secondarySmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.secondaryMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.secondaryLarge;
        }
      case ActionButtonType.tertiary:
        switch (size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.tertiarySmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.tertiaryMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.tertiaryLarge;
        }
      case ActionButtonType.tertiaryNoBorder:
        switch (size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.tertiaryNoBorderSmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.tertiaryNoBorderMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.tertiaryNoBorderLarge;
        }
    }
  }
}
