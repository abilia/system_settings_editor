import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class WebLink extends StatelessWidget {
  const WebLink({
    Key key,
    @required this.text,
    @required this.urlString,
  }) : super(key: key);

  final String text;
  final String urlString;
  @override
  Widget build(BuildContext context) => GestureDetector(
      child: Text(
        'myAbilia',
        style: TextStyle(
            color: AbiliaColors.red,
            decoration: TextDecoration.underline,
            decorationColor: AbiliaColors.red,
            fontSize: 16),
      ),
      onTap: () => launch('https://myabilia.com/user-create'));
}
