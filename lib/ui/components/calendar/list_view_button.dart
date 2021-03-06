import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

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
            color: AbiliaColors.transparentWhite10,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(AbiliaIcons.list_order,
                  color: themeData.textTheme.button.color),
            ),
            Text(
              Translator.of(context).translate.listView,
              style: themeData.textTheme.button,
            ),
          ],
        ),
      ),
    );
  }
}
