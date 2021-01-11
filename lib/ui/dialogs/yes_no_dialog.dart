import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class YesNoDialog extends StatelessWidget {
  final VoidCallback onNoPressed;
  final VoidCallback onYesPressed;
  final Widget heading;
  final String bodyText;
  const YesNoDialog({
    Key key,
    this.heading,
    this.bodyText,
    this.onNoPressed,
    this.onYesPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.center,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 64,
                    ),
                    child: Center(
                        child: Text(
                      bodyText,
                      style: abiliaTextTheme.bodyText1,
                    )),
                  ),
                ),
                Container(
                  color: AbiliaColors.black80,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: NoButton(
                            onPressed: onNoPressed,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: YesButton(
                            onPressed: onYesPressed,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
