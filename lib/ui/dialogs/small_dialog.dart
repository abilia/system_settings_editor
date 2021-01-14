import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class SmallDialog extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;
  final Widget heading;
  final Widget body;
  const SmallDialog({
    Key key,
    this.heading,
    this.body,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 68,
                  color: AbiliaColors.black80,
                  child: Center(child: heading),
                ),
                Container(
                  color: AbiliaColors.white110,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 64,
                  ),
                  child: Center(child: body),
                ),
                BottomNavigation(
                  backNavigationWidget: backNavigationWidget,
                  forwardNavigationWidget: forwardNavigationWidget,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
