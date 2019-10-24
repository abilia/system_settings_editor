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
  Widget build(BuildContext context) => 
     Padding(
       padding: const EdgeInsets.all(32.0),
       child: RaisedButton(
            onPressed: onPressed,
            child: Text(label),
            color: Theme.of(context).accentColor,
            disabledColor: Theme.of(context).disabledColor,
    ),
     );
}
