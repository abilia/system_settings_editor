import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key key}) : super(key: key);
  final widgets = const <Widget>[
    DotSetting(),
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
          separatorBuilder: (context, index) => const SizedBox(height: 12.0)),
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
      label: Text(Translator.of(context).translate.logout),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LogoutPage()),
      ),
    );
  }
}

class DotSetting extends StatelessWidget {
  const DotSetting({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => SwitchField(
        leading: Icon(AbiliaIcons.options),
        label: Text(Translator.of(context).translate.showTimeDots),
        value: state.dotsInTimepillar,
        onChanged: (v) => BlocProvider.of<SettingsBloc>(context)
            .add(DotsInTimepillarUpdated(v)),
      ),
    );
  }
}
