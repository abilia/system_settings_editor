import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key key,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
  }) : super(key: key);

  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AbiliaColors.black80,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (forwardNavigationWidget != null) ...[
              Expanded(child: backNavigationWidget),
              const SizedBox(width: 8),
              Expanded(child: forwardNavigationWidget),
            ] else
              Center(child: backNavigationWidget),
          ],
        ),
      ),
    );
  }
}
