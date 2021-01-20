import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class ActionButton extends StatelessWidget {
  static const size = 48.0;
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.width = size,
    this.height = size,
    this.themeData,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final ThemeData themeData;
  final Widget child;
  final VoidCallback onPressed;
  final double width, height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = themeData ?? Theme.of(context);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => SizedBox(
          width: width,
          height: height,
          child: FlatButton(
            color: theme.buttonColor,
            shape: onPressed != null
                ? theme.buttonTheme.shape
                : transparentOutlineInputBorder,
            disabledTextColor: theme.disabledColor,
            highlightColor: theme.highlightColor,
            padding: padding,
            textColor: theme.textTheme.button.color,
            child: child,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
