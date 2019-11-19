import 'package:flutter/material.dart';

class AbiliaButton extends StatelessWidget {
  const AbiliaButton({
    Key key,
    this.padding = const EdgeInsets.all(32),
    @required this.label,
    @required this.onPressed,
  }) : super(key: key);

  final String label;
  final Function onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: RaisedButton(
          disabledColor: Theme.of(context).disabledColor,
          disabledTextColor: Theme.of(context).textTheme.button.color,
          textColor: Theme.of(context).textTheme.button.color,
          onPressed: onPressed,
          child: Text(label),
        ),
      );
}
