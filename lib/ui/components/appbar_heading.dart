// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class AppBarHeading extends StatelessWidget {
  const AppBarHeading({
    Key key,
    @required this.text,
    this.iconData,
  }) : super(key: key);

  final String text;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: text,
      child: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: AbiliaColors.white,
            ),
        child: DefaultTextStyle(
          style: abiliaTextTheme.headline5.copyWith(
            color: AbiliaColors.white,
            fontSize: 22.0.s,
          ),
          child: Row(
            children: [
              const Spacer(flex: 100),
              if (iconData != null) ...[
                Icon(iconData),
                SizedBox(width: 8.s),
              ],
              Text(text),
              const Spacer(flex: 114),
            ],
          ),
        ),
      ),
    );
  }
}
