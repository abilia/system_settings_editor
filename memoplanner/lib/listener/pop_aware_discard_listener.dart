import 'package:memoplanner/ui/all.dart';

class PopAwareDiscardListener extends StatelessWidget {
  final Widget child;
  final bool Function(BuildContext context) discardDialogCondition;

  const PopAwareDiscardListener({
    required this.child,
    required this.discardDialogCondition,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _discardChanges(context),
      child: child,
    );
  }

  Future<bool> _discardChanges(BuildContext context) async {
    final showDiscardDialog = discardDialogCondition(context);
    if (showDiscardDialog) {
      return _showDiscardWarningDialog(context);
    }
    return true;
  }

  Future<bool> _showDiscardWarningDialog(BuildContext context) async {
    final discardChanges = await showViewDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const DiscardWarningDialog(),
    );
    return discardChanges ?? false;
  }
}
