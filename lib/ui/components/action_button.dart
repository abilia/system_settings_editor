import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.width = 48,
    this.height = 48,
    this.themeData,
  }) : super(key: key);

  final ThemeData themeData;
  final Widget child;
  final Function onPressed;
  final double width, height;

  @override
  Widget build(BuildContext context) => Theme(
        data: themeData ?? Theme.of(context),
        child: Builder(
          builder: (context) => SizedBox(
            width: width,
            height: height,
            child: FlatButton(
              color: Theme.of(context).buttonColor,
              highlightColor: Theme.of(context).highlightColor,
              padding: const EdgeInsets.all(8),
              textColor: Theme.of(context).textTheme.button.color,
              child: child,
              onPressed: onPressed,
            ),
          ),
        ),
      );
}
