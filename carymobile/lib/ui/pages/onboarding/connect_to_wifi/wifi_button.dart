part of 'connect_to_wifi_page.dart';

class WifiButton extends StatelessWidget {
  const WifiButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonGreen(
      leading: const Icon(AbiliaIcons.wifi),
      text: Lt.of(context).connected,
      onPressed: () async => const AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch(),
    );
  }
}
