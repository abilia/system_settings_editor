import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CheckActivityConfirmDialog extends StatelessWidget {
  final ActivityDay activityDay;
  final String? message;

  const CheckActivityConfirmDialog({
    Key? key,
    required this.activityDay,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final signedOff = activityDay.isSignedOff;

    final bodyText = message ??
        (signedOff
            ? translate.unCheckActivityQuestion
            : translate.checkActivityQuestion);
    return ViewDialog(
      heading: AppBarHeading(
        text: signedOff ? translate.uncheck : translate.check,
        iconData: signedOff ? AbiliaIcons.handiUncheck : AbiliaIcons.handiCheck,
      ),
      body: Tts(
        child: Text(
          bodyText,
          style: abiliaTextTheme.bodyText1,
        ),
      ),
      backNavigationWidget: const NoButton(),
      forwardNavigationWidget: const YesButton(),
    );
  }
}
