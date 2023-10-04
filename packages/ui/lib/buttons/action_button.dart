import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ButtonStyle style;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double iconSize, spacing;
  final bool iconLeft;

  const ActionButton({
    required this.text,
    required this.icon,
    required this.style,
    required this.onPressed,
    required this.padding,
    required this.iconSize,
    required this.spacing,
    this.iconLeft = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
    );
    return TextButton(
      style: style,
      onPressed: onPressed,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconLeft) iconWidget,
            SizedBox(width: iconLeft ? spacing : spacing + iconSize),
            Flexible(
              child: Text(
                text,
                softWrap: true,
                maxLines: 1,
              ),
            ),
            SizedBox(width: iconLeft ? spacing + iconSize : spacing),
            if (!iconLeft) iconWidget,
          ],
        ),
      ),
    );
  }
}
