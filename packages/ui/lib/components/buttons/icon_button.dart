import 'package:flutter/material.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/buttons/icon_button/icon_button_themes.dart';

class SeagullIconButton extends StatelessWidget {
  final IconData icon;
  final ButtonSize size;
  final bool border;
  final VoidCallback? onPressed;

  const SeagullIconButton({
    required this.icon,
    required this.size,
    required this.border,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconButtonTheme = _getTheme(context);
    return IconButton(
      style: iconButtonTheme.buttonStyle,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  SeagullIconButtonTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (size) {
      case ButtonSize.small:
        return border
            ? abiliaTheme.iconButtons.small
            : abiliaTheme.iconButtons.noBorderSmall;
      case ButtonSize.medium:
        return border
            ? abiliaTheme.iconButtons.medium
            : abiliaTheme.iconButtons.noBorderMedium;
      case ButtonSize.large:
        return border
            ? abiliaTheme.iconButtons.large
            : abiliaTheme.iconButtons.noBorderLarge;
    }
  }
}
