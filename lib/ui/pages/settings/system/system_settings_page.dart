import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.technical_settings,
      title: t.system,
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.numeric_keyboard,
          text: t.codeProtect,
          navigateTo: const CodeProtectPage(),
        ),
        const TextToSpeechSwitch(),
        PickField(
          leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
          text: Text(t.androidSettings),
          onTap: AndroidIntents.openSettings,
        ),
        const PermissionPickField(),
        MenuItemPickField(
          icon: AbiliaIcons.information,
          text: t.about,
          navigateTo: const AboutPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.power_off_on,
          text: t.logout,
          navigateTo: const LogoutPage(),
        ),
      ],
    );
  }
}
