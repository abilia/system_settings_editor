import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

import 'all.dart';

class LicenseExpiredDialog extends StatelessWidget {
  const LicenseExpiredDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return ViewDialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 128, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              AbiliaIcons.gewa_radio_error,
              size: 96,
              color: AbiliaColors.red,
            ),
            SizedBox(
              height: 80,
            ),
            Text(
              translator.licenseExpired,
              style: abiliaTheme.textTheme.headline6,
            ),
            Text(
              translator.licenseExpiredMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
