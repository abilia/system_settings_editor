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
        iconData: AbiliaIcons.passwordProtection,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AbiliaIcons.gewaRadioError,
            size: layout.iconSize.huge,
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
        icon: AbiliaIcons.openDoor,
        onPressed: () => Navigator.of(context).maybePop(false),
      ),
    );
  }
}
