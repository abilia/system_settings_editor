import 'package:memoplanner/ui/all.dart';

class DiscardWarningDialog extends StatelessWidget {
  const DiscardWarningDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      body: Column(
        children: [
          const Icon(
            AbiliaIcons.gewaRadioError,
            color: AbiliaColors.red,
            size: 144,
          ),
          Tts(
            child: Text(
              'Are you sure you want to discard your changes',
              style: headline6,
            ),
          ),
        ],
      ),
      bottomNavigationColor: AbiliaColors.white110,
      backNavigationWidget: IconAndTextButton(
        text: 'Keep editing',
        icon: AbiliaIcons.closeProgram,
        onPressed: () async => await Navigator.of(context).maybePop(false),
        style: actionButtonStyleNoneTransparantDark,
      ),
      forwardNavigationWidget: IconAndTextButton(
        text: 'Discard',
        icon: AbiliaIcons.deleteAllClear,
        onPressed: () async => await Navigator.of(context).maybePop(true),
        style: iconTextButtonStyleRed,
      ),
    );
  }
}
