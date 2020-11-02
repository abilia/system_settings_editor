import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class LicenseExpiredDialog extends StatelessWidget {
  const LicenseExpiredDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return WarningDialog(
      icon: Icon(
        AbiliaIcons.gewa_radio_error,
        size: hugeIconSize,
        color: AbiliaColors.red,
      ),
      heading: translator.licenseExpired,
      text: Tts(
        child: Text(
          translator.licenseExpiredMessage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
