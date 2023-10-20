import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/helper_box/helper_box_themes.dart';

enum HelperBoxState {
  caution,
  info,
  error,
  success,
}

enum HelperBoxSize { medium, large }

class SeagullHelperBox extends StatelessWidget {
  final String text;
  final IconData? icon;
  final HelperBoxState state;
  final HelperBoxSize size;

  const SeagullHelperBox({
    required this.text,
    required this.state,
    required this.size,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    final helperBoxTheme = _getTheme(context);
    final iconAndTextBoxTheme = helperBoxTheme.iconAndTextBoxTheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: iconAndTextBoxTheme.border,
        color: color,
      ),
      child: Padding(
        padding: iconAndTextBoxTheme.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconAndTextBoxTheme.iconSize,
              ),
              SizedBox(width: iconAndTextBoxTheme.iconSpacing),
            ],
            Expanded(
              child: Text(
                text,
                style: iconAndTextBoxTheme.textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    final colors = AbiliaTheme.of(context).colors;
    switch (state) {
      case HelperBoxState.caution:
        return colors.yellow.shade100;
      case HelperBoxState.info:
        return colors.greyscale.shade100;
      case HelperBoxState.error:
        return colors.peach.shade100;
      case HelperBoxState.success:
        return colors.secondary.shade100;
    }
  }

  SeagullHelperBoxTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (size) {
      case HelperBoxSize.medium:
        return abiliaTheme.helperBox.medium;
      case HelperBoxSize.large:
        return abiliaTheme.helperBox.large;
    }
  }
}
