import 'package:flutter/material.dart';

import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class RemoveButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget icon;
  final String text;

  const RemoveButton({
    Key key,
    this.onTap,
    this.icon,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            color: AbiliaColors.transparentRed[80],
            borderRadius: borderRadius,
            border: Border.all(
              color: AbiliaColors.red,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                icon ?? Container(),
                SizedBox(
                  width: 4,
                ),
                text == null
                    ? Container()
                    : Text(text,
                        style: abiliaTextTheme.bodyText1
                            .copyWith(color: AbiliaColors.white, height: 1)),
              ],
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
