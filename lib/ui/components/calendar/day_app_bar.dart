import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/theme.dart';

class DayAppBar extends StatelessWidget {
  final Widget leftAction;
  final Widget rightAction;

  static const _emptyAction = SizedBox(
    width: 48,
  );

  final DateTime day;
  const DayAppBar(
      {Key key,
      this.leftAction = _emptyAction,
      this.rightAction = _emptyAction,
      this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    final themeData = weekDayTheme[day.weekday];
    return AppBar(
      brightness: getThemeAppBarBrightness()[day.weekday],
      elevation: 0.0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: leftAction,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM', langCode).format(day),
                    style: themeData.textTheme.title,
                  ),
                  Text(
                    '${Translator.of(context).translate.week} ${day.getWeekNumber()}',
                    style: themeData.textTheme.subhead,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: rightAction,
            ),
          ],
        ),
      ),
    );
  }
}
