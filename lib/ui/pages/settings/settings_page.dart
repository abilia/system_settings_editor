import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.settings,
      title: t.settings,
      widgets: [
        if (Config.isMP) ...[
          MenuItemPickField(
            icon: AbiliaIcons.month,
            text: t.calendar,
            navigateTo: const CalendarSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.menuSetup,
            text: t.functions,
            navigateTo: const FunctionSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.myPhotos,
            text: t.imagePicker,
            navigateTo: const ImagePickerSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.appMenu,
            text: t.menu,
            navigateTo: const MenuSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.technicalSettings,
            text: t.system,
            navigateTo: const SystemSettingsPage(),
          ),
        ] else if (Config.isMPGO) ...[
          Tts(child: Text(t.calendar)),
          MenuItemPickField(
            icon: AbiliaIcons.handiAlarmVibration,
            text: t.alarmSettings,
            navigateTo: const AlarmSettingsPage(),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          Tts(child: Text(t.system)),
          const TextToSpeechSwitch(),
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
        if (Config.alpha) const FakeTicker(),
      ],
    );
  }
}

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) => Row(children: [
        Expanded(
          child: SwitchField(
            value: settingsState.textToSpeech,
            leading: const Icon(AbiliaIcons.speakText),
            onChanged: (v) => context.read<SettingsCubit>().setTextToSpeech(v),
            child: Text(Translator.of(context).translate.textToSpeech),
          ),
        ),
        Padding(
          padding: layout.settings.textToSpeechPadding,
          child: InfoButton(
            onTap: () => showViewDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => const LongPressInfoDialog(),
            ),
          ),
        ),
      ]),
    );
  }
}

class PermissionPickField extends StatelessWidget {
  const PermissionPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, state) => Stack(
        children: [
          PickField(
            leading: const Icon(AbiliaIcons.menuSetup),
            text: Text(Translator.of(context).translate.permissions),
            onTap: () async {
              final authProviders = copiedAuthProviders(context);
              context.read<PermissionCubit>().checkAll();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const PermissionsPage(),
                  ),
                  settings: const RouteSettings(name: 'PermissionPage'),
                ),
              );
            },
          ),
          if (state.importantPermissionMissing)
            Positioned(
              top: layout.settings.permissionsDotPosition,
              right: layout.settings.permissionsDotPosition,
              child: const OrangeDot(),
            ),
        ],
      ),
    );
  }
}
