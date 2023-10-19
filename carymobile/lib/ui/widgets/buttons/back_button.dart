import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:flutter/material.dart';

class CaryBackButton extends StatelessWidget {
  const CaryBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonBlack(
      onPressed: Navigator.of(context).maybePop,
      text: Lt.of(context).back,
      leading: const Icon(AbiliaIcons.navigationPrevious),
    );
  }
}
