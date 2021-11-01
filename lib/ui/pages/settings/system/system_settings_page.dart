import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.technicalSettings,
      title: t.system,
      widgets: [
        MenuItemPickField(
          icon: AbiliaIcons.numericKeyboard,
          text: t.codeProtect,
          navigateTo: const CodeProtectPage(),
        ),
        const TextToSpeechSwitch(),
        PickField(
          leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
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
          icon: AbiliaIcons.powerOffOn,
          text: t.logout,
          navigateTo: const LogoutPage(),
        ),
      ],
    );
  }
}
