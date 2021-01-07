import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class IconAndTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onPressed;

  const IconAndTextButton({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.theme,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts(
      data: text,
      child: FlatButton.icon(
        height: 64,
        icon: IconTheme(
          data: theme.iconTheme,
          child: Icon(icon),
        ),
        label: Text(
          text,
          style: theme.textTheme.button,
        ),
        color: theme.buttonColor,
        onPressed: onPressed,
      ),
    );
  }
}
