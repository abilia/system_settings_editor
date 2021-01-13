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
    return Tts(
      data: text,
      child: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: AbiliaColors.white,
            ),
        child: DefaultTextStyle(
          style: abiliaTextTheme.headline5.copyWith(
            color: AbiliaColors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null) ...[
                Icon(iconData),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
