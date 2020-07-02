import 'package:flutter/material.dart';
import 'package:seagull/ui/theme.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.width = 48,
    this.height = 48,
    this.themeData,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final ThemeData themeData;
  final Widget child;
  final Function onPressed;
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
