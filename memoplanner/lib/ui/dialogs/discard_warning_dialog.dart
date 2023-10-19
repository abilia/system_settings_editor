import 'package:memoplanner/ui/all.dart';

class DiscardWarningDialog extends StatelessWidget {
  const DiscardWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
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
              style: titleLarge,
            ),
          ),
        ],
      ),
      verticalButtons: layout.go,
      bottomNavigationColor: ViewDialog.light,
      backNavigationWidget: LightGreyButton(
        text: translate.keepEditing,
        icon: AbiliaIcons.closeProgram,
        onPressed: () async => Navigator.of(context).maybePop(false),
      ),
      forwardNavigationWidget: RedButton(
        text: translate.discard,
        icon: AbiliaIcons.deleteAllClear,
        onPressed: () async => Navigator.of(context).maybePop(true),
      ),
    );
  }
}
