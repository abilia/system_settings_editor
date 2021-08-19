// @dart=2.9

import 'package:auto_size_text/auto_size_text.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key key,
    @required this.rows,
  }) : super(key: key);

  final AppBarTitleRows rows;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline6;
    return DefaultTextStyle(
      style: style,
      overflow: TextOverflow.ellipsis,
      child: Tts.data(
        data: '${rows.row1} ${rows.row2} ${rows.row3}',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (rows.row1.isNotEmpty) Text(rows.row1),
            if (rows.row2.isNotEmpty) Text(rows.row2),
            if (rows.row3.isNotEmpty)
              AutoSizeText(
                rows.row3,
                maxLines: 1,
                minFontSize: style.fontSize,
                overflowReplacement:
                    rows.row3Short.isNotEmpty ? Text(rows.row3Short) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class AppBarTitleRows {
  final String row1, row2, row3, row3Short;

  const AppBarTitleRows._(
    this.row1, [
    this.row2 = '',
    this.row3 = '',
    this.row3Short = '',
  ]);

  static DateFormat longDate(String langCode) =>
      DateFormat('d MMMM y', langCode);
  static DateFormat shortDate(String langCode) =>
      DateFormat('d MMM yy', langCode);

  factory AppBarTitleRows.day({
    bool displayWeekDay = true,
    bool displayPartOfDay = true,
    bool displayDate = true,
    @required DateTime currentTime,
    @required DateTime day,
    @required DayParts dayParts,
    @required String langCode,
    @required Translated translator,
  }) {
    final weekday = displayWeekDay ? DateFormat.EEEE(langCode).format(day) : '';
    final daypart = displayPartOfDay
        ? _getPartOfDay(
            currentTime.isAtSameDay(day),
            currentTime.hour,
            currentTime.dayPart(dayParts),
            translator,
          )
        : '';
    final date = displayDate ? longDate(langCode).format(day) : '';
    final dateShort = displayDate ? shortDate(langCode).format(day) : '';
    return AppBarTitleRows._(weekday, daypart, date, dateShort);
  }

  static String _getPartOfDay(
    bool today,
    int hour,
    DayPart part,
    Translated translator,
  ) {
    if (today) {
      switch (part) {
        case DayPart.night:
          return translator.night;
        case DayPart.evening:
          return translator.evening;
        case DayPart.day:
          if (hour > 11) {
            return translator.afternoon;
          }
          return translator.forenoon;
        case DayPart.morning:
          return translator.morning;
        default:
          return '';
      }
    }
    return '';
  }

  factory AppBarTitleRows.week({
    @required DateTime selectedWeekStart,
    @required DateTime selectedDay,
    @required bool showWeekNumber,
    @required bool showYear,
    @required String langCode,
    @required Translated translator,
  }) {
    final displayWeekDay = selectedDay.isSameWeek(selectedWeekStart);
    final day =
        displayWeekDay ? DateFormat.EEEE(langCode).format(selectedDay) : '';
    final weekTranslation =
        displayWeekDay ? translator.week : translator.week.capitalize();
    final week = showWeekNumber
        ? '$weekTranslation ${selectedWeekStart.getWeekNumber()}'
        : '';
    final year = showYear ? DateFormat.y(langCode).format(selectedDay) : '';

    return AppBarTitleRows._(day, week, year);
  }

  factory AppBarTitleRows.month({
    @required DateTime currentTime,
    @required String langCode,
    @required bool showYear,
  }) =>
      AppBarTitleRows._(
        DateFormat.MMMM(langCode).format(currentTime),
        showYear ? DateFormat.y(langCode).format(currentTime) : '',
      );
}
