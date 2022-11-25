import 'package:memoplanner/ui/all.dart';

class DiscardWarningDialog extends StatelessWidget {
  const DiscardWarningDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      body: Column(
        children: [
          Icon(
            AbiliaIcons.gewaRadioError,
            color: AbiliaColors.red,
            size: layout.icon.huge,
          ),
          Tts(
            child: Text(
              translate.confirmDiscard,
              style: headline6,
            ),
          ),
        ],
      ),
      bottomNavigationColor: ViewDialog.light,
      backNavigationWidget: IconAndTextButton(
        text: translate.keepEditing,
        icon: AbiliaIcons.closeProgram,
        onPressed: () => Navigator.of(context).maybePop(false),
        style: iconTextButtonStyleGrey,
      ),
      forwardNavigationWidget: IconAndTextButton(
        text: translate.discard,
        icon: AbiliaIcons.deleteAllClear,
        onPressed: () => Navigator.of(context).maybePop(true),
        style: iconTextButtonStyleRed,
      ),
    );
  }
}
