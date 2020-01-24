import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ListViewButton extends StatelessWidget {
  final Function onPressed;
  final ThemeData themeData;

  const ListViewButton(
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
              child: Icon(AbiliaIcons.phone_log,
                  color: themeData.textTheme.button.color),
            ),
            Text(
              Translator.of(context).translate.listView,
              style: themeData.textTheme.button,
            ),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
