import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CalendarAppBar extends StatelessWidget {
  final Widget leftAction;
  final Widget rightAction;
  final Widget clockReplacement;
  final AppBarTitleRows rows;
  final bool crossedOver;
  final DateTime day;
  final DayColor calendarDayColor;

  static final _emptyAction = SizedBox(width: 48.s);

  static final double clockPadding = 8.s;
  static final Size size = Size.fromHeight(68.s);

  const CalendarAppBar({
    Key key,
    this.leftAction,
    this.rightAction,
    this.clockReplacement,
    this.crossedOver = false,
    @required this.rows,
    @required this.day,
    this.calendarDayColor = DayColor.noColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = weekdayTheme(
      dayColor: calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return AnimatedTheme(
      key: TestKey.animatedTheme,
      data: theme.theme,
      child: Builder(
        builder: (context) => AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0.s,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  leftAction ?? _emptyAction,
                  SizedBox(width: clockPadding + actionButtonMinSize),
                  Flexible(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: AppBarTitle(rows: rows),
                        ),
                        if (crossedOver)
                          CrossOver(
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
                      ],
                    ),
                  ),
                  clockReplacement ?? const AbiliaClock(),
                  SizedBox(width: clockPadding),
                  rightAction ?? _emptyAction,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
