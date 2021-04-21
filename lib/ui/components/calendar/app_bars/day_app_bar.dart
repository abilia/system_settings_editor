import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leftAction;
  final Widget rightAction;
  final Widget clock;
  final DateTime day;

  const DayAppBar({
    Key key,
    this.leftAction,
    this.rightAction,
    this.clock,
    @required this.day,
  }) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
          return BlocBuilder<ClockBloc, DateTime>(
            builder: (context, time) => CalendarAppBar(
              day: day,
              calendarDayColor: memoSettingsState.calendarDayColor,
              rows: AppBarTitleRows.day(
                displayWeekDay: memoSettingsState.activityDisplayWeekDay,
                displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
                displayDate: memoSettingsState.activityDisplayDate,
                currentTime: time,
                day: day,
                dayParts: memoSettingsState.dayParts,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                translator: Translator.of(context).translate,
              ),
              rightAction: rightAction,
              leftAction: leftAction,
              crossedOver: day.isDayBefore(time),
              showClock: memoSettingsState.activityDisplayClock,
            ),
          );
        },
      );
}
