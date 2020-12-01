import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class NotificationPermissionOffWarningDialog extends StatelessWidget {
  final GestureTapCallback onOk;

  const NotificationPermissionOffWarningDialog({
    Key key,
    @required this.onOk,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return WarningDialog(
      onOk: () async {
        await Navigator.of(context).maybePop();
        await onOk();
      },
      icon: const Icon(
        AbiliaIcons.ir_error,
        size: hugeIconSize,
        color: AbiliaColors.orange,
      ),
      heading: Translator.of(context).translate.turnOffNotifications,
      text: Tts(
        child: Text(
          translate.turnOffNotificationsBody,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class NotificationPermissionWarningDialog extends StatelessWidget {
  const NotificationPermissionWarningDialog({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WarningDialog(
      icon: const Icon(
        AbiliaIcons.ir_error,
        size: hugeIconSize,
        color: AbiliaColors.orange,
      ),
      heading: Translator.of(context).translate.allowNotifications,
      text: NotificationBodyTextWarning(),
    );
  }
}

@visibleForTesting
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
        label: translate.allowNotificationsDescription,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: b1,
          children: [
            TextSpan(text: '${translate.allowNotificationsDescription1} '),
            buildSettingsLinkTextSpan(context),
          ],
        ),
      ),
    );
  }
}
