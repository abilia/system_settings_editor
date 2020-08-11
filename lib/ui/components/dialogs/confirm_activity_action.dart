import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ConfirmActivityActionDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final String title;

  const ConfirmActivityActionDialog({
    Key key,
    @required this.activityOccasion,
    @required this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(title, style: theme.textTheme.headline6),
      onOk: () => Navigator.of(context).maybePop(true),
      child: AbsorbPointer(
          child: ActivityCard(
        activityOccasion: activityOccasion,
        preview: true,
      )),
    );
  }
}
