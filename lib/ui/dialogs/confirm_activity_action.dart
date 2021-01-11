import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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
      heading: Text(
        title,
        style: theme.textTheme.headline6,
      ),
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

class CheckActivityConfirmDialog extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final String message;

  const CheckActivityConfirmDialog({
    Key key,
    @required this.activityOccasion,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final signedOff = activityOccasion.isSignedOff;

    final bodyText = message ??
        (signedOff
            ? translate.unCheckActivityQuestion
            : translate.checkActivityQuestion);
    final text = signedOff ? translate.uncheck : translate.check;

    return YesNoDialog(
      onNoPressed: () => Navigator.of(context).maybePop(false),
      onYesPressed: () => Navigator.of(context).maybePop(true),
      heading: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: AbiliaColors.white,
            ),
        child: DefaultTextStyle(
            style: abiliaTextTheme.headline5.copyWith(
              color: AbiliaColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(signedOff
                    ? AbiliaIcons.handi_uncheck
                    : AbiliaIcons.handi_check),
                SizedBox(
                  width: 8,
                ),
                Text(text),
              ],
            )),
      ),
      bodyText: bodyText,
    );
  }
}
