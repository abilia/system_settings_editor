import 'package:memoplanner/ui/all.dart';

class SaveNoteWarningDialog extends StatelessWidget {
  const SaveNoteWarningDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return ViewDialog(
      body: Column(
        children: [
          Icon(
            AbiliaIcons.gewaRadioError,
            color: AbiliaColors.white140,
            size: layout.icon.huge,
          ),
          Tts(
            child: Text(
              translate.saveNoteQuestion,
              style: titleLarge,
            ),
          ),
        ],
      ),
      bottomNavigationColor: ViewDialog.light,
      backNavigationWidget: LightGreyButton(
        text: translate.cancelChanges,
        icon: AbiliaIcons.closeProgram,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      forwardNavigationWidget: GreenButton(
        text: translate.saveNote,
        icon: AbiliaIcons.ok,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
