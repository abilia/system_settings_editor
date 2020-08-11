import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/dialogs/settings/time_illustration.dart';
import 'package:seagull/ui/theme.dart';

class TimePillarSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = darkButtonTheme;
    return Theme(
      data: theme,
      child: ViewDialog(
        heading: Text(translate.timepillarSettings,
            style: theme.textTheme.headline6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PickField(
              leading: Icon(AbiliaIcons.options),
              label: Text(
                translate.activityDuration,
                style: abiliaTheme.textTheme.bodyText1,
              ),
              active: false,
              onTap: () async {
                await Navigator.of(context).maybePop();
                await showViewDialog(
                    context: context, builder: (context) => TimeIllustration());
              },
            ),
          ],
        ),
      ),
    );
  }
}
