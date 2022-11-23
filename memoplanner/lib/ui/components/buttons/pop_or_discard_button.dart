import 'package:memoplanner/ui/all.dart';

enum ButtonType {
  cancel,
  previous,
}

class PopOrDiscardButton extends StatefulWidget {
  final ButtonType type;
  final bool Function(BuildContext context) discardDialogCondition;

  const PopOrDiscardButton({
    required this.type,
    required this.discardDialogCondition,
    Key? key,
  }) : super(key: key);

  @override
  State<PopOrDiscardButton> createState() => _PopOrDiscardButtonState();
}

class _PopOrDiscardButtonState extends State<PopOrDiscardButton> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case ButtonType.previous:
        return PreviousButton(onPressed: () => _showDialogOrPop());
      case ButtonType.cancel:
        return CancelButton(onPressed: () => _showDialogOrPop());
    }
  }

  Future _showDialogOrPop() async {
    final showDiscardDialog = widget.discardDialogCondition(context);
    if (showDiscardDialog) {
      return _showDiscardWarningDialog();
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _showDiscardWarningDialog() async {
    final discardChanges = await showViewDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const DiscardWarningDialog(),
    );
    if (discardChanges == true && mounted) {
      Navigator.of(context).maybePop();
    }
  }
}
