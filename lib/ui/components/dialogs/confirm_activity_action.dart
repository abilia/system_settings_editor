import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ConfirmActivityActionDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final String title;
  final String extraMessage;

  const ConfirmActivityActionDialog({
    Key key,
    @required this.activityOccasion,
    @required this.title,
    this.extraMessage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(title, style: theme.textTheme.headline6),
      onOk: () => Navigator.of(context).maybePop(true),
      child: Column(
        children: [
          ActivityCard(
            activityOccasion: activityOccasion,
            preview: true,
          ),
          if (extraMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tts(child: Text(extraMessage)),
              ),
            ),
        ],
      ),
    );
  }
}
