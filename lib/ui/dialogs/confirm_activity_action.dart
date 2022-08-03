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
    return YesNoDialog(
      heading: signedOff ? translate.undo : translate.check,
      headingIcon:
          signedOff ? AbiliaIcons.handiUncheck : AbiliaIcons.handiCheck,
      text: message ??
          (signedOff
              ? translate.unCheckActivityQuestion
              : translate.checkActivityQuestion),
    );
  }
}
