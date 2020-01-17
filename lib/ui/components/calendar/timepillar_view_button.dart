import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class TimePillarViewButton extends StatelessWidget {
  final Function onPressed;
  final ThemeData themeData;

  const TimePillarViewButton(
      {Key key, @required this.onPressed, @required this.themeData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: FlatButton(
        color: themeData.buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            width: 1,
            color: AbiliaColors.transparantWhite[10],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                AbiliaIcons.timeline,
                color: themeData.textTheme.button.color,
              ),
            ),
            Text(
              Translator.of(context).translate.timePillarView,
              style: themeData.textTheme.button,
            ),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
