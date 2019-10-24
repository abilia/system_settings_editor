import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final Function onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 48,
        height: 48,
        child: RaisedButton(
          padding: const EdgeInsets.all(8),
          child: child,
          onPressed: onPressed,
          color: Theme.of(context).buttonColor,
        ),
      );
}
