import 'package:flutter/widgets.dart';
import 'package:seagull/ui/all.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String text;

  const InfoDialog({
    Key? key,
    required this.text,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: title,
        iconData: AbiliaIcons.gewa_radio_error,
      ),
      body: Tts(child: Text(text)),
      backNavigationWidget: OkButton(
        onPressed: () => Navigator.of(context).maybePop(true),
      ),
    );
  }
}
