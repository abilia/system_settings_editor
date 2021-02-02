import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class AvailableForPage extends StatefulWidget {
  final bool secret;

  const AvailableForPage({Key key, @required this.secret}) : super(key: key);

  @override
  _AvailableForPageState createState() => _AvailableForPageState(secret);
}

class _AvailableForPageState extends State<AvailableForPage> {
  _AvailableForPageState(this.secret);
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
              value: true,
              leading: const Icon(AbiliaIcons.password_protection),
              text: Text(translate.onlyMe),
            ),
            const SizedBox(height: 8.0),
            RadioField(
              groupValue: secret,
              onChanged: _onSelected,
              value: false,
              leading: const Icon(AbiliaIcons.user_group),
              text: Text(translate.meAndSupportPersons),
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
