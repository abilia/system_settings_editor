import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/settings_db.dart';
import 'package:seagull/tts/tts_handler.dart';
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
      label: Config.isMP ? t.settings : null,
      widgets: [
        PickField(
          leading: const Icon(AbiliaIcons.numericKeyboard),
          text: Text(t.codeProtect),
          onTap: () async {
            final accessGranted = await codeProtectAccess(
              context,
              restricted: (codeSettings) => codeSettings.protectCodeProtect,
              name: t.codeProtect,
            );
            if (accessGranted) {
              final authProviders = copiedAuthProviders(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const CodeProtectSettingsPage(),
                  ),
                  settings:
                      const RouteSettings(name: 'CodeProtectSettingsPage'),
                ),
              );
            }
          },
        ),
        PickField(
          leading: const Icon(AbiliaIcons.speakText),
          text: Text(t.textToSpeech),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider<SpeechSettingsCubit>(
                create: (context) => SpeechSettingsCubit(
                    settingsDb: GetIt.I<SettingsDb>(),
                    acapelaTts: GetIt.I<TtsInterface>() as AcapelaTtsHandler),
                child: const SpeechSupportSettingsPage(),
              ),
              settings: const RouteSettings(name: 'SpeechSupportSettingsPage'),
            ),
          ),
        ),
        PickField(
          leading: const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
          text: Text(t.androidSettings),
          onTap: () async {
            final accessGranted = await codeProtectAccess(
              context,
              restricted: (codeSettings) => codeSettings.protectAndroidSettings,
              name: t.androidSettings,
            );
            if (accessGranted) {
              AndroidIntents.openSettings();
            }
          },
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
