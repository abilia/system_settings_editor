import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);
  final widgets = const <Widget>[
    TextToSpeechSwitch(),
    PermissionPickField(),
    LogoutPickField(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(title: Translator.of(context).translate.menu),
      body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 16.0, 20.0),
          itemBuilder: (context, i) => widgets[i],
          itemCount: widgets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8.0)),
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
            leading: Icon(
              AbiliaIcons.speak_text,
              size: smallIconSize,
            ),
            text: Text(Translator.of(context).translate.textToSpeech),
            onChanged: (v) =>
                context.read<SettingsBloc>().add(TextToSpeechUpdated(v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InfoButton(
            onTap: () => showViewDialog(
              context: context,
              builder: (context) => LongPressInfoDialog(),
            ),
          ),
        ),
      ]),
    );
  }
}

class LongPressInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = darkButtonTheme;
    return Theme(
      data: theme,
      child: ViewDialog(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            Stack(children: [
              Transform.scale(
                scale: 0.85,
                child: buildPreviewActivityCard(translate),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Icon(
                    AbiliaIcons.speak_on_entry,
                    size: hugeIconSize,
                  ),
                ),
              ),
            ]),
            SizedBox(
              height: 85,
            ),
            Tts(
              child: Text(
                translate.longpressToSpeak,
                style: abiliaTextTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Tts(
                child: Text(
                  translate.longPressInfoText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ActivityCard buildPreviewActivityCard(Translated translate) {
    return ActivityCard(
      activityOccasion: ActivityOccasion(
        Activity.createNew(
          title: translate.lunch,
          startTime: DateTime.now().withTime(TimeOfDay(hour: 12, minute: 0)),
          duration: 1.hours(),
        ),
        DateTime.now(),
        Occasion.future,
      ),
      preview: true,
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
                top: 8.0,
                right: 8.0,
                child: OrangeDot(),
              ),
          ],
        ),
      );
}
