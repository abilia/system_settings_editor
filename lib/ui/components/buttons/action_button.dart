import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class ActionButton extends StatelessWidget {
  static final size = 48.0.s;
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.themeData,
  }) : super(key: key);

  final ThemeData themeData;
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = themeData ?? Theme.of(context);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => SizedBox(
          width: size,
          height: size,
          child: FlatButton(
            color: theme.buttonColor,
            shape: onPressed != null
                ? theme.buttonTheme.shape
                : transparentOutlineInputBorder,
            disabledTextColor: theme.disabledColor,
            highlightColor: theme.highlightColor,
            padding: EdgeInsets.all(8.s),
            textColor: theme.textTheme.button.color,
            child: child,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
