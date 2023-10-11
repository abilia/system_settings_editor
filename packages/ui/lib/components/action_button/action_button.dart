import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/action_button/action_button_theme.dart';

part 'action_button_primary.dart';

part 'action_button_secondary.dart';

part 'action_button_tertiary.dart';

sealed class ActionButton extends StatelessWidget {
  final String text;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final ActionButtonTheme Function(AbiliaTheme) themeBuilder;

  const ActionButton({
    required this.themeBuilder,
    required this.text,
    required this.onPressed,
    required this.leadingIcon,
    required this.trailingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final leadingIcon = this.leadingIcon;
    final trailingIcon = this.trailingIcon;
    final abiliaTheme = AbiliaTheme.of(context);
    final actionButtonTheme = themeBuilder(abiliaTheme);
    return TextButton(
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
}
