import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

import 'all.dart';

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
        size: 96,
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
