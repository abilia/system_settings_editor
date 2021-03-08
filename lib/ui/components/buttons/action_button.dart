import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.style,
  }) : super(key: key);

  final ButtonStyle style;
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
}

class ActionButtonLight extends StatelessWidget {
  const ActionButtonLight({
    Key key,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ActionButton(
        onPressed: onPressed,
        style: actionButtonStyleLight,
        child: child,
      );
}

class ActionButtonDark extends StatelessWidget {
  const ActionButtonDark({
    Key key,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ActionButton(
        onPressed: onPressed,
        style: actionButtonStyleDark,
        child: child,
      );
}
class ActionButtonBlack extends StatelessWidget {
  const ActionButtonBlack({
    Key key,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ActionButton(
        onPressed: onPressed,
        style: actionButtonStyleBlack,
        child: child,
      );
}
