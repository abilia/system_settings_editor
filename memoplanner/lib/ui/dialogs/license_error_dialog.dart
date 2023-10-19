import 'package:memoplanner/ui/all.dart';

class LicenseErrorDialog extends StatelessWidget {
  final String? heading;
  final String message;

  const LicenseErrorDialog({
    required this.message,
    this.heading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return ViewDialog(
      heading: AppBarHeading(
        text: heading ?? translate.error,
        iconData: AbiliaIcons.passwordProtection,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AbiliaIcons.gewaRadioError,
            size: layout.icon.huge,
            color: AbiliaColors.red,
          ),
          SizedBox(height: layout.dialog.iconTextDistance),
          Tts(
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      backNavigationWidget: LightButton(
        text: Lt.of(context).toLogin,
        icon: AbiliaIcons.openDoor,
        onPressed: () async => Navigator.of(context).maybePop(false),
      ),
    );
  }
}
