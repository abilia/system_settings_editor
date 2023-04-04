import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.technicalSettings,
      title: t.system,
      label: Config.isMP ? t.settings : null,
      widgets: [
        PickField(
          leading: const Icon(AbiliaIcons.numericKeyboard),
          text: Text(t.codeProtect),
          onTap: () async {
            final authProviders = copiedAuthProviders(context);
            final navigator = Navigator.of(context);
            final accessGranted = await codeProtectAccess(
              context,
              restricted: (codeSettings) => codeSettings.protectCodeProtect,
              name: t.codeProtect,
            );
            if (accessGranted) {
              await navigator.push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const CodeProtectSettingsPage(),
                  ),
                  settings: (CodeProtectSettingsPage).routeSetting(),
                ),
              );
            }
          },
        ),
        PickField(
          leading: const Icon(AbiliaIcons.speakText),
          text: Text(t.textToSpeech),
          onTap: () async => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: copiedAuthProviders(context),
                child: SpeechSupportSettingsPage(
                  textToSpeech:
                      context.read<SpeechSettingsCubit>().state.textToSpeech,
                  speechRate:
                      context.read<SpeechSettingsCubit>().state.speechRate,
                ),
              ),
              settings: (SpeechSupportSettingsPage).routeSetting(),
            ),
          ),
        ),
        PickField(
          leading: const Icon(AbiliaIcons.android),
          text: Text(t.androidSettings),
          onTap: () async {
            final accessGranted = await codeProtectAccess(
              context,
              restricted: (codeSettings) => codeSettings.protectAndroidSettings,
              name: t.androidSettings,
            );
            if (accessGranted) {
              await AndroidIntents.openSettings();
            }
          },
        ),
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
