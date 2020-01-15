import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class OkBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Translated translate = Translator.of(context).translate;
    return BottomAppBar(
      child: SafeArea(
        child: Container(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Theme(
                  data:
                      Theme.of(context).copyWith(buttonTheme: greenButtonTheme),
                  child: FlatButton(
                    color: AbiliaColors.green,
                    child: Text(
                      translate.ok,
                      style: Theme.of(context)
                          .textTheme
                          .body2
                          .copyWith(color: AbiliaColors.white),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
