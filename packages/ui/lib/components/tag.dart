import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/tag/tag_themes.dart';

enum TagSize { size700, size600 }

class SeagullTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final TagSize size;
  final Color color;

  const SeagullTag({
    required this.text,
    required this.size,
    required this.color,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tagTheme = _getTheme(context);
    final iconAndTextBoxTheme = tagTheme.iconAndTextBoxTheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: iconAndTextBoxTheme.border,
        color: color,
      ),
      child: Padding(
        padding: iconAndTextBoxTheme.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconAndTextBoxTheme.iconSize,
              ),
              SizedBox(width: iconAndTextBoxTheme.iconSpacing),
            ],
            Flexible(
              child: Text(
                text,
                style: iconAndTextBoxTheme.textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SeagullTagTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (size) {
      case TagSize.size700:
        return abiliaTheme.tags.size700;
      case TagSize.size600:
        return abiliaTheme.tags.size600;
    }
  }
}
