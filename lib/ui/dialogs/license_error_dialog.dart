import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class LicenseErrorDialog extends StatelessWidget {
  final String? heading;
  final String message;

  const LicenseErrorDialog({
    Key? key,
    this.heading,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return ViewDialog(
      heading: AppBarHeading(
        text: heading ?? translator.error,
        iconData: AbiliaIcons.password_protection,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AbiliaIcons.gewa_radio_error,
            size: hugeIconSize,
            color: AbiliaColors.red,
          ),
          SizedBox(height: 24.0.s),
          Tts(
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      backNavigationWidget: LightButton(
        text: Translator.of(context).translate.toLogin,
        icon: AbiliaIcons.open_door,
        onPressed: () => Navigator.of(context).maybePop(false),
      ),
    );
  }
}
