import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:flutter/material.dart';

class CaryCloseButton extends StatelessWidget {
  final VoidCallback? onLongPress;
  const CaryCloseButton({super.key, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    return ActionButtonBlack(
      onPressed: Navigator.of(context).maybePop,
      onLongPress: onLongPress,
      text: Lt.of(context).close,
      leading: const Icon(AbiliaIcons.cancel),
    );
  }
}
