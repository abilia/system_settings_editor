import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class SelectAvailableForDialog extends StatelessWidget {
  final bool secret;

  const SelectAvailableForDialog({Key key, @required this.secret})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(
        translate.activityAvailableFor,
        style: theme.textTheme.headline6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioField(
            groupValue: secret,
            onChanged: Navigator.of(context).maybePop,
            value: false,
            leading: Icon(AbiliaIcons.user_group),
            text: Text(translate.meAndSupportPersons),
          ),
          SizedBox(height: 8.0),
          RadioField(
            key: TestKey.onlyMe,
            groupValue: secret,
            onChanged: Navigator.of(context).maybePop,
            value: true,
            leading: Icon(AbiliaIcons.password_protection),
            text: Text(translate.onlyMe),
          ),
        ],
      ),
    );
  }
}
