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
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(12.0),
          ),
          onPressed: onPressed,
          child: Text(label)),
    );
  }
}
