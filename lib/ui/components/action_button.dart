import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.width = 48,
    this.height = 48,
    this.buttonThemeData,
  }) : super(key: key);

  final ButtonThemeData buttonThemeData;
  final Widget child;
  final Function onPressed;
  final double width, height;

  @override
  Widget build(BuildContext context) => Theme(
    data: buttonThemeData  != null ? Theme.of(context).copyWith(buttonTheme: buttonThemeData) : Theme.of(context),
      child: SizedBox(
          width: width,
          height: height,
          child: RaisedButton(
            padding: const EdgeInsets.all(8),
            child: child,
            onPressed: onPressed,
          ),
        ),
  );
}
