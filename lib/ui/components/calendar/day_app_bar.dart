import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
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
      @required this.day})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).toLanguageTag();
    final textStyle = weekDayTheme[day.weekday].textTheme.headline6;
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
                      alignment: Alignment.center,
                      child: DayAppBarTitle(
                          langCode: langCode,
                          currentTime: time,
                          day: day,
                          textStyle: textStyle),
                    ),
                    if (day.isDayBefore(time))
                      CrossOver(color: textStyle.color),
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

class DayAppBarTitleRows {
  final String row1;
  final String row2;

  DayAppBarTitleRows(this.row1, this.row2);

  factory DayAppBarTitleRows.fromSettings({
    bool displayWeekDay = true,
    bool displayPartOfDay = true,
    bool displayDate = true,
    DateTime currentTime,
    DateTime day,
    DayParts dayParts,
    String langCode,
    Translated translator,
  }) {
    final part = currentTime.dayPart(dayParts);
    final partOfDay = _getPartOfDay(currentTime, day, part, translator);
    var row1 =
        displayWeekDay ? '${DateFormat('EEEE', langCode).format(day)}' : '';
    var row2 = displayDate
        ? DateFormat('d MMMM y', langCode).format(day)
        : displayPartOfDay
            ? partOfDay
            : '';
    if (displayDate && displayPartOfDay && partOfDay.isNotEmpty) {
      row1 += displayWeekDay ? ', $partOfDay' : partOfDay;
    }
    return DayAppBarTitleRows(row1, row2);
  }

  static String _getPartOfDay(
    DateTime currentTime,
    DateTime day,
    DayPart part,
    Translated translator,
  ) {
    if (currentTime.onlyDays() == day.onlyDays()) {
      switch (part) {
        case DayPart.night:
          return translator.night;
        case DayPart.evening:
          return translator.evening;
        case DayPart.afternoon:
          return translator.afternoon;
        case DayPart.forenoon:
          return translator.forenoon;
        case DayPart.morning:
          return translator.morning;
        default:
          return '';
      }
    }
    return '';
  }
}

class DayAppBarTitle extends StatelessWidget {
  const DayAppBarTitle({
    Key key,
    @required this.langCode,
    @required this.currentTime,
    @required this.day,
    @required this.textStyle,
  }) : super(key: key);

  final String langCode;
  final DateTime currentTime, day;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
      final rows = DayAppBarTitleRows.fromSettings(
        displayWeekDay: memoSettingsState.activityDisplayWeekDay,
        displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
        displayDate: memoSettingsState.activityDisplayDate,
        currentTime: currentTime,
        day: day,
        dayParts: memoSettingsState.dayParts,
        langCode: langCode,
        translator: Translator.of(context).translate,
      );
      return Tts(
        data: rows.row1 + rows.row2,
        child: Column(
          key: TestKey.dayAppBarTitle,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (rows.row1.isNotEmpty)
              Text(
                rows.row1,
                style: textStyle,
              ),
            if (rows.row2.isNotEmpty)
              Text(
                rows.row2,
                style: textStyle,
              ),
          ],
        ),
      );
    });
  }
}
