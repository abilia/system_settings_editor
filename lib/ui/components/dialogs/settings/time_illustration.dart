import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class TimeIllustation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => ViewDialog(
        heading:
            Text(translate.activityDuration, style: theme.textTheme.headline6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField<bool>(
              groupValue: state.dotsInTimepillar,
              onChanged: (v) => BlocProvider.of<SettingsBloc>(context)
                  .add(DotsInTimepillarUpdated(v)),
              value: true,
              child: Row(
                children: <Widget>[
                  Icon(AbiliaIcons.options),
                  const SizedBox(width: 12),
                  Text(translate.dots),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            RadioField<bool>(
              groupValue: state.dotsInTimepillar,
              onChanged: (v) => BlocProvider.of<SettingsBloc>(context)
                  .add(DotsInTimepillarUpdated(v)),
              value: false,
              child: Row(
                children: <Widget>[
                  Icon(AbiliaIcons.flarp),
                  const SizedBox(width: 12),
                  Text(translate.edge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
