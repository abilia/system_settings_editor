import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/theme.dart';

class DayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leftAction;
  final Widget rightAction;

  static const _emptyAction = SizedBox(width: 48);

  final DateTime day;
  const DayAppBar(
      {Key key,
      this.leftAction = _emptyAction,
      this.rightAction = _emptyAction,
      this.day})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).toLanguageTag();
    final themeData = weekDayTheme[day.weekday];
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              leftAction,
              BlocBuilder<ClockBloc, DateTime>(
                builder: (context, time) => Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: <Widget>[
                          Text(
                            DateFormat('EEEE, d MMM', langCode).format(day),
                            style: themeData.textTheme.title,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        '${Translator.of(context).translate.week} ${day.getWeekNumber()}',
                        style: themeData.textTheme.subhead,
                      ),
                    ),
                    if (day.isDayBefore(time))
                      CrossOver(color: themeData.accentColor),
                  ],
                ),
              ),
              rightAction,
            ],
          ),
        ),
      ),
    );
  }
}
