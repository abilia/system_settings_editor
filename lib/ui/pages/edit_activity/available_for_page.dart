import 'package:seagull/ui/all.dart';

class AvailableForPage extends StatefulWidget {
  final bool secret;

  const AvailableForPage({Key? key, required this.secret}) : super(key: key);

  @override
  _AvailableForPageState createState() => _AvailableForPageState();
}

class _AvailableForPageState extends State<AvailableForPage> {
  bool? secret;

  @override
  void initState() {
    super.initState();
    secret = widget.secret;
  }

  void _onSelected(bool? value) => setState(() => secret = value);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.unlock,
        title: translate.availableFor,
      ),
      body: Padding(
        padding: layout.formPadding.frame,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField<bool?>(
              groupValue: secret,
              onChanged: _onSelected,
              value: true,
              leading: const Icon(AbiliaIcons.passwordProtection),
              text: Text(translate.onlyMe),
            ),
            SizedBox(height: 8.0.s),
            RadioField<bool?>(
              groupValue: secret,
              onChanged: _onSelected,
              value: false,
              leading: const Icon(AbiliaIcons.userGroup),
              text: Text(translate.meAndSupportPersons),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(secret),
        ),
      ),
    );
  }
}
