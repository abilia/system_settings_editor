import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class SelectAvailableForDialog extends StatefulWidget {
  final bool secret;

  const SelectAvailableForDialog({Key key, @required this.secret})
      : super(key: key);

  @override
  _SelectAvailableForDialogState createState() =>
      _SelectAvailableForDialogState(secret);
}

class _SelectAvailableForDialogState extends State<SelectAvailableForDialog> {
  _SelectAvailableForDialogState(this.secret);
  bool secret;
  void _onSelected(bool value) => setState(() => secret = value);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField(
              groupValue: secret,
              onChanged: _onSelected,
              value: false,
              leading: Icon(AbiliaIcons.user_group),
              text: Text(translate.meAndSupportPersons),
            ),
            SizedBox(height: 8.0),
            RadioField(
              key: TestKey.onlyMe,
              groupValue: secret,
              onChanged: _onSelected,
              value: true,
              leading: Icon(AbiliaIcons.password_protection),
              text: Text(translate.onlyMe),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(secret),
        ),
      ),
    );
  }
}
