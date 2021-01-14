import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class LicenseExpiredDialog extends StatelessWidget {
  const LicenseExpiredDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return SmallDialog(
      heading: AppBarHeading(
        text: translator.licenseExpired,
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
          const SizedBox(height: 24.0),
          Tts(
            child: Text(
              translator.licenseExpiredMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      backNavigationWidget: GreyButton(
        text: Translator.of(context).translate.toLogin,
        icon: AbiliaIcons.open_door,
        onPressed: () => Navigator.of(context).maybePop(false),
      ),
    );
  }
}
