import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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
    return ViewDialog(
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
