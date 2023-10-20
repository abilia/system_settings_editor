import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return SettingsBasePage(
      icon: AbiliaIcons.technicalSettings,
      title: translate.system,
      label: Config.isMP ? translate.settings : null,
      widgets: [
        PickField(
          leading: const Icon(AbiliaIcons.numericKeyboard),
          text: Text(translate.codeProtect),
          onTap: () async {
            final authProviders = copiedAuthProviders(context);
            final accessGranted = await codeProtectAccess(
              context,
              restricted: (codeSettings) => codeSettings.protectCodeProtect,
              name: translate.codeProtect,
            );
            if (accessGranted && context.mounted) {
              await Navigator.of(context).push(
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
          text: Text(translate.textToSpeech),
          onTap: () async {
            unawaited(context.read<VoicesCubit>().loadAvailableVoices());
            await Navigator.of(context).push(
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
            );
          },
        ),
        PickField(
          leading: const Icon(AbiliaIcons.android),
          text: Text(translate.androidSettings),
          onTap: () async {
            final accessGranted = await codeProtectAccess(
              context,
              restricted: (codeSettings) => codeSettings.protectAndroidSettings,
              name: translate.androidSettings,
            );
            if (accessGranted) {
              await AndroidIntents.openSettings();
            }
          },
        ),
        MenuItemPickField(
          icon: AbiliaIcons.information,
          text: translate.about,
          navigateTo: const AboutPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.powerOffOn,
          text: translate.logout,
          navigateTo: const LogoutPage(),
        ),
      ],
    );
  }
}
