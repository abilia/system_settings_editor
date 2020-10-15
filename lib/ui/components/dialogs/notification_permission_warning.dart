import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';

class NotificationPermissionWarningDialog extends StatelessWidget {
  const NotificationPermissionWarningDialog({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      verticalPadding: 0.0,
      leftPadding: 32.0,
      rightPadding: 32.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 128),
          const Icon(
            AbiliaIcons.ir_error,
            size: 96.0,
            color: AbiliaColors.orange,
          ),
          const Spacer(flex: 80),
          Tts(
            child: Text(
              Translator.of(context).translate.allowNotifications,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(height: 8.0),
          NotificationBodyTextWarning(),
          const Spacer(flex: 199),
        ],
      ),
    );
  }
}

class NotificationBodyTextWarning extends StatelessWidget {
  const NotificationBodyTextWarning({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final b1 = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(color: AbiliaColors.black75);
    final translate = Translator.of(context).translate;
    return Tts.fromSemantics(
      SemanticsProperties(
          multiline: true,
          label: translate.allowNotificationsDescription1 +
              translate.allowNotificationsDescriptionSettingsLink +
              translate.allowNotificationsDescription2),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: b1,
          children: [
            TextSpan(text: translate.allowNotificationsDescription1),
            TextSpan(
              text: translate.allowNotificationsDescriptionSettingsLink,
              style: b1.copyWith(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pop();
                  return Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PermissionsPage(),
                      settings: RouteSettings(name: 'PermissionPage'),
                    ),
                  );
                },
            ),
            TextSpan(
              text: translate.allowNotificationsDescription2,
              style: b1,
            ),
          ],
        ),
      ),
    );
  }
}
