import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class DeleteActivityDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;

  const DeleteActivityDialog({Key key, @required this.activityOccasion})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.deleteActivity, style: theme.textTheme.headline6),
      onOk: () => Navigator.of(context).maybePop(true),
      child: AbsorbPointer(
          child: ActivityCard(activityOccasion: activityOccasion)),
    );
  }
}
