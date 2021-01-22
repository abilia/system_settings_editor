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
                child: Tts(
                  child: Text(extraMessage),
                ),
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
    return SmallDialog(
      heading: AppBarHeading(
        text: signedOff ? translate.uncheck : translate.check,
        iconData:
            signedOff ? AbiliaIcons.handi_uncheck : AbiliaIcons.handi_check,
      ),
      body: Tts(
        child: Text(
          bodyText,
          style: abiliaTextTheme.bodyText1,
        ),
      ),
      backNavigationWidget: GreyButton(
        key: TestKey.noButton,
        text: Translator.of(context).translate.no,
        icon: AbiliaIcons.close_program,
        onPressed: () => Navigator.of(context).maybePop(false),
      ),
      forwardNavigationWidget: GreenButton(
        key: TestKey.yesButton,
        text: Translator.of(context).translate.yes,
        icon: AbiliaIcons.ok,
        onPressed: () => Navigator.of(context).maybePop(true),
      ),
    );
  }
}
