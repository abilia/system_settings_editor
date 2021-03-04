import 'package:flutter/material.dart';

import 'package:seagull/ui/all.dart';

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
    return Tts.fromSemantics(
      SemanticsProperties(
        button: true,
        label: text,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AbiliaColors.transparentRed[80],
              borderRadius: borderRadius,
              border: Border.all(color: AbiliaColors.red, width: 1.s),
            ),
            padding: EdgeInsets.fromLTRB(8.s, 6.s, 8.s, 6.s),
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
      ),
    );
  }
}
