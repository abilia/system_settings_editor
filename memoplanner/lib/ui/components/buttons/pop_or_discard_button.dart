import 'package:memoplanner/ui/all.dart';

enum ButtonType {
  cancel,
  previous,
}

class PopOrDiscardButton extends StatefulWidget {
  final bool Function(BuildContext context) unchangedCondition;
  final ButtonType type;

  const PopOrDiscardButton({
    required this.unchangedCondition,
    required this.type,
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
        return PreviousButton(onPressed: () => _popOrDiscard());
      case ButtonType.cancel:
        return CancelButton(onPressed: () => _popOrDiscard());
    }
  }

  Future _popOrDiscard() async {
    final unchanged = widget.unchangedCondition(context);
    if (unchanged) {
      return Navigator.of(context).maybePop();
    }
    _showDiscardWarningDialog();
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
