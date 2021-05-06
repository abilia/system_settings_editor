import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
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
        if (Config.isMP)
          MenuItemPickField(
            icon: AbiliaIcons.numeric_keyboard,
            text: t.codeProtect,
            navigateTo: CodeProtectPage(),
          ),
        const TextToSpeechSwitch(),
        if (Config.isMP) const AndroidSettingsPickField(),
        const PermissionPickField(),
        MenuItemPickField(
          icon: AbiliaIcons.information,
          text: t.about,
          navigateTo: AboutPage(),
        ),
        MenuItemPickField(
          icon: AbiliaIcons.power_off_on,
          text: t.logout,
          navigateTo: LogoutPage(),
        ),
      ],
    );
  }
}

class AndroidSettingsPickField extends StatelessWidget {
  const AndroidSettingsPickField({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickField(
      leading: Icon(AbiliaIcons.past_picture_from_windows_clipboard),
      text: Text(Translator.of(context).translate.androidSettings),
      onTap: openAndroidSettings,
    );
  }
}

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) => Row(children: [
        Expanded(
          child: SwitchField(
            value: settingsState.textToSpeech,
            leading: Icon(AbiliaIcons.speak_text),
            text: Text(Translator.of(context).translate.textToSpeech),
            onChanged: (v) =>
                context.read<SettingsBloc>().add(TextToSpeechUpdated(v)),
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
