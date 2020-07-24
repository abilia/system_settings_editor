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
        text,
        style: Theme.of(context).textTheme.bodyText1.copyWith(
              color: AbiliaColors.red,
              decoration: TextDecoration.underline,
            ),
      ),
      onTap: () => launch(urlString));
}
