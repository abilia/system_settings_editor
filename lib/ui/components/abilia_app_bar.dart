import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final bool hasClose;
  const AbiliaAppBar(
      {Key key,
      @required this.title,
      this.height = 68.0,
      this.hasClose = false})
      : super(key: key);
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Stack(
              children: <Widget>[
                if (hasClose)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CloseButton(),
                  ),
                Center(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: AbiliaColors.white),
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

class CloseButton extends StatelessWidget {
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
