import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/image_picker_settings_page.dart';
import 'package:seagull/ui/pages/settings/menu_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      widgets: [
        if (Config.isMP) ...[
          MenuItemPickField(
            icon: AbiliaIcons.month,
            text: t.calendar,
            navigateTo: CalendarSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.menu_setup,
            text: t.functions,
            navigateTo: FunctionSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.my_photos,
            text: t.imagePicker,
            navigateTo: ImagePickerSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.app_menu,
            text: t.menu,
            navigateTo: MenuSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.stop_watch,
            text: t.countdown,
            navigateTo: CountdownSettingsPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.technical_settings,
            text: t.system,
            navigateTo: SystemSettingsPage(),
          ),
        ] else if (Config.isMPGO) ...[
          Tts(child: Text(t.calendar)),
          MenuItemPickField(
            icon: AbiliaIcons.handi_alarm_vibration,
            text: t.alarmSettings,
            navigateTo: AlarmSettingsPage(),
          ),
          SizedBox(height: 8.s),
          Tts(child: Text(t.system)),
          const TextToSpeechSwitch(),
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
        if (Config.alpha) const FakeTicker(),
      ],
      icon: AbiliaIcons.settings,
      title: t.settings,
    );
  }
}

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) => Row(children: [
        Expanded(
          child: SwitchField(
            value: settingsState.textToSpeech,
            leading: Icon(AbiliaIcons.speak_text),
            onChanged: (v) =>
                context.read<SettingsBloc>().add(TextToSpeechUpdated(v)),
            child: Text(Translator.of(context).translate.textToSpeech),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.0.s, 0, 4.0.s, 0),
          child: InfoButton(
            onTap: () => showViewDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => LongPressInfoDialog(),
            ),
          ),
        ),
      ]),
    );
  }
}

class PermissionPickField extends StatelessWidget {
  const PermissionPickField({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) => Stack(
          children: [
            PickField(
              leading: Icon(AbiliaIcons.menu_setup),
              text: Text(Translator.of(context).translate.permissions),
              onTap: () async {
                context.read<PermissionBloc>().checkAll();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: PermissionsPage(),
                    ),
                    settings: RouteSettings(name: 'PermissionPage'),
                  ),
                );
              },
            ),
            if (state.importantPermissionMissing)
              Positioned(
                top: 8.0.s,
                right: 8.0.s,
                child: OrangeDot(),
              ),
          ],
        ),
      );
}
