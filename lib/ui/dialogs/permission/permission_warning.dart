import 'package:flutter/gestures.dart';
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
    return ViewDialog(
      expanded: true,
      bodyPadding:
          EdgeInsets.symmetric(horizontal: ViewDialog.horizontalPadding),
      backNavigationWidget: GreyButton(
        icon: AbiliaIcons.close_program,
        text: translate.no,
        onPressed: Navigator.of(context).maybePop,
      ),
      forwardNavigationWidget: GreenButton(
        key: TestKey.okDialog,
        icon: AbiliaIcons.ok,
        text: translate.yes,
        onPressed: () async {
          await Navigator.of(context).maybePop();
          onOk();
        },
      ),
      body: _WarningContent(
        body: Tts(
          child: Text(
            translate.turnOffNotificationsBody,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: AbiliaColors.black75),
            textAlign: TextAlign.center,
          ),
        ),
        heading: translate.turnOffNotifications,
      ),
    );
  }
}

class NotificationPermissionWarningDialog extends StatelessWidget {
  const NotificationPermissionWarningDialog({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => ViewDialog(
        expanded: true,
        bodyPadding:
            EdgeInsets.symmetric(horizontal: ViewDialog.horizontalPadding),
        backNavigationWidget: const CloseButton(),
        body: _WarningContent(
          heading: Translator.of(context).translate.allowNotifications,
          body: const NotificationBodyTextWarning(),
        ),
      );
}

class _WarningContent extends StatelessWidget {
  const _WarningContent({Key key, this.heading, this.body}) : super(key: key);
  final String heading;
  final Widget body;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(height: 128.0.s),
          Icon(
            AbiliaIcons.ir_error,
            size: hugeIconSize,
            color: AbiliaColors.orange,
          ),
          SizedBox(height: 80.0.s),
          Tts(
            child: Text(
              heading,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: 8.0.s),
          body,
        ],
      );
}

@visibleForTesting
class NotificationBodyTextWarning extends StatelessWidget {
  const NotificationBodyTextWarning({Key key}) : super(key: key);

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
            TextSpan(
              text: '${translate.allowNotificationsDescription1} ',
              style: b1,
            ),
            buildSettingsLinkTextSpan(context),
          ],
        ),
      ),
    );
  }
}
