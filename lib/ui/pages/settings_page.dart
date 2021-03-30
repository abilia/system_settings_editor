import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/fakes/all.dart';

import 'package:seagull/ui/all.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);
  final widgets = const <Widget>[
    TextToSpeechSwitch(),
    PermissionPickField(),
    AboutPickField(),
    LogoutPickField(),
    if (Config.alpha) FakeTicker(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.menu,
        iconData: AbiliaIcons.settings,
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(12.0.s, 20.0.s, 16.0.s, 20.0.s),
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.0.s),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: BackButton(),
      ),
    );
  }
}

class LogoutPickField extends StatelessWidget {
  const LogoutPickField({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickField(
      leading: Icon(AbiliaIcons.power_off_on),
      text: Text(Translator.of(context).translate.logout),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CopiedAuthProviders(
            blocContext: context,
            child: LogoutPage(),
          ),
          settings: RouteSettings(name: 'LogoutPage'),
        ),
      ),
    );
  }
}

class AboutPickField extends StatelessWidget {
  const AboutPickField({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => PickField(
        leading: Icon(AbiliaIcons.information),
        text: Text(Translator.of(context).translate.about),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: AboutPage(),
            ),
            settings: RouteSettings(name: 'AboutPage'),
          ),
        ),
      );
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
