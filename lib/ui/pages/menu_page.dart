import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/settings_bloc.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);
  final widgets = const <Widget>[
    TextToSpeechSwitch(),
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
      key: TestKey.availibleFor,
      leading: Icon(AbiliaIcons.power_off_on),
      text: Text(Translator.of(context).translate.logout),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LogoutPage(),
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
            text: Text('Text to speech'),
            onChanged: (v) =>
                context.bloc<SettingsBloc>().add(TextToSpeechUpdated(v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              border: Border.fromBorderSide(BorderSide(
                color: AbiliaColors.transparentBlack30,
              )),
              color: AbiliaColors.transparentBlack20,
            ),
            child: Icon(
              AbiliaIcons.handi_info,
              size: smallIconSize,
            ),
          ),
        )
      ]),
    );
  }
}
