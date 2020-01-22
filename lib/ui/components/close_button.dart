import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class AbiliaCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(buttonTheme: actionButtonTheme.copyWith(minWidth: 65)),
      child: FlatButton(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        color: AbiliaColors.transparantWhite[20],
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            width: 1,
            color: AbiliaColors.transparantWhite[15],
          ),
        ),
        child: Text(
          Translator.of(context).translate.close,
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
