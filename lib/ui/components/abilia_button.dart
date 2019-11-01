import 'package:flutter/material.dart';

class AbiliaButton extends StatelessWidget {
  const AbiliaButton({
    Key key,
    @required this.label,
    @required this.onPressed,
  }) : super(key: key);

  final String label;
  final Function onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: RaisedButton(
          disabledColor: Theme.of(context).disabledColor,
          disabledTextColor: Theme.of(context).textTheme.button.color,
          onPressed: onPressed,
          child: Text(label),
        ),
      );
}
