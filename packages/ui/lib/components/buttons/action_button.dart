import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/numericals.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final bool showIconLeft, showIconRight;

  const ActionButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.style,
    this.showIconLeft = true,
    this.showIconRight = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const spacing = numerical200;
    return TextButton(
      style: style ?? actionButtonPrimary900,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && showIconLeft)
            Padding(
              padding: const EdgeInsets.only(right: spacing),
              child: Icon(icon),
            ),
          Flexible(
            child: Text(
              text,
              softWrap: true,
              maxLines: 1,
            ),
          ),
          if (icon != null && showIconRight)
            Padding(
              padding: const EdgeInsets.only(left: spacing),
              child: Icon(icon),
            ),
        ],
      ),
    );
  }
}
