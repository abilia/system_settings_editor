import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class CheckActivityConfirmDialog extends StatelessWidget {
  final ActivityDay activityDay;
  final String? message;

  const CheckActivityConfirmDialog({
    required this.activityDay,
    this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final signedOff = activityDay.isSignedOff;
    return YesNoDialog(
      heading: signedOff ? translate.undo : translate.check,
      headingIcon:
          signedOff ? AbiliaIcons.handiUncheck : AbiliaIcons.handiCheck,
      text: message ??
          (signedOff
              ? translate.unCheckActivityQuestion
              : translate.completedQuestion),
    );
  }
}
