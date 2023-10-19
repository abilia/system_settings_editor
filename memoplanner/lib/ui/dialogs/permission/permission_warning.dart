import 'package:memoplanner/ui/all.dart';

class NotificationPermissionOffWarningDialog extends StatelessWidget {
  final GestureTapCallback onOk;

  const NotificationPermissionOffWarningDialog({
    required this.onOk,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return ViewDialog(
      expanded: true,
      bodyPadding: layout.templates.m4,
      backNavigationWidget: LightButton(
        icon: AbiliaIcons.closeProgram,
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
                .bodyMedium
                ?.copyWith(color: AbiliaColors.black75),
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
    super.key,
  });
  @override
  Widget build(BuildContext context) => ViewDialog(
        expanded: true,
        bodyPadding: layout.templates.m4,
        backNavigationWidget: const CloseButton(),
        body: _WarningContent(
          heading: Lt.of(context).allowNotifications,
          body: const NotificationBodyTextWarning(),
        ),
      );
}

class _WarningContent extends StatelessWidget {
  const _WarningContent({
    required this.heading,
    required this.body,
  });
  final String heading;
  final Widget body;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(height: layout.dialog.fullscreenTop),
          Icon(
            AbiliaIcons.irError,
            size: layout.icon.huge,
            color: AbiliaColors.orange,
          ),
          SizedBox(height: layout.dialog.fullscreenIconDistance),
          Tts(
            child: Text(
              heading,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          body,
        ],
      );
}

@visibleForTesting
class NotificationBodyTextWarning extends StatelessWidget {
  const NotificationBodyTextWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyMedium = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AbiliaColors.black75);
    final translate = Lt.of(context);
    return Tts.fromSemantics(
      SemanticsProperties(
        multiline: true,
        label: translate.allowNotificationsDescription,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: bodyMedium,
          children: [
            TextSpan(
              text: '${translate.allowNotificationsDescription1} ',
              style: bodyMedium,
            ),
            buildSettingsLinkTextSpan(context),
          ],
        ),
      ),
    );
  }
}
