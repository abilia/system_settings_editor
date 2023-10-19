import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    required this.rows,
    this.style,
    super.key,
  });

  final AppBarTitleRows rows;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final style =
        this.style ?? Theme.of(context).textTheme.titleLarge ?? titleLarge;
    final fontSize = style.fontSize;
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
            if (rows.row3.isNotEmpty && fontSize != null)
              AutoSizeText(
                rows.row3,
                maxLines: 1,
                minFontSize: rows.row3MinTextSize ?? fontSize,
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
  final double? row3MinTextSize;

  const AppBarTitleRows._({
    required this.row1,
    this.row2 = '',
    this.row3 = '',
    this.row3Short = '',
    this.row3MinTextSize,
  });

  static DateFormat longDate(String langCode) =>
      DateFormat('d MMMM y', langCode);

  static DateFormat shortDate(String langCode) =>
      DateFormat('d MMM yy', langCode);

  factory AppBarTitleRows.day({
    required DateTime currentTime,
    required DateTime day,
    required DayParts dayParts,
    required DayPart dayPart,
    required String langCode,
    required Lt translate,
    required DayAppBarSettings settings,
    bool compactDay = false,
    bool currentNight = false,
  }) {
    final weekdayString = settings.showWeekday
        ? currentNight
            ? nightDay(currentTime, dayParts, langCode)
            : DateFormat.EEEE(langCode).format(day)
        : '';
    final dayPartString =
        (!dayPart.isNight || currentNight) && settings.showDayPeriod
            ? _getPartOfDay(
                currentTime.isAtSameDay(day),
                currentTime.hour,
                dayPart,
                translate,
              )
            : '';
    final date = settings.showDate ? longDate(langCode).format(day) : '';
    final dateShort = settings.showDate ? shortDate(langCode).format(day) : '';
    return AppBarTitleRows._(
      row1: weekdayString + (compactDay ? ', $dayPartString' : ''),
      row2: compactDay ? '' : dayPartString,
      row3: date,
      row3Short: dateShort,
    );
  }

  static String nightDay(
    DateTime currentTime,
    DayParts dayParts,
    String langCode,
  ) {
    final afterMidnight = currentTime.difference(currentTime.onlyDays());
    final beforeMidnight = afterMidnight >= dayParts.night;
    if (beforeMidnight) {
      final firstDay = DateFormat.E(langCode).format(currentTime);
      final secondDay = DateFormat.E(langCode).format(currentTime.nextDay());
      return '$firstDay - $secondDay';
    } else {
      final firstDay = DateFormat.E(langCode).format(currentTime.previousDay());
      final secondDay = DateFormat.E(langCode).format(currentTime);
      return '$firstDay - $secondDay';
    }
  }

  static String _getPartOfDay(
    bool today,
    int hour,
    DayPart part,
    Lt translate,
  ) {
    if (today) {
      switch (part) {
        case DayPart.night:
          return translate.night;
        case DayPart.evening:
          return translate.evening;
        case DayPart.day:
          if (hour > 11) {
            return translate.afternoon;
          }
          return translate.midMorning;
        case DayPart.morning:
          return translate.earlyMorning;
        default:
          return '';
      }
    }
    return '';
  }

  factory AppBarTitleRows.week({
    required DateTime selectedWeekStart,
    required DateTime selectedDay,
    required WeekCalendarSettings settings,
    required String langCode,
    required Lt translate,
  }) {
    final displayWeekday = selectedDay.isSameWeekAndYear(selectedWeekStart);
    final day =
        displayWeekday ? DateFormat.EEEE(langCode).format(selectedDay) : '';
    final weekTranslation =
        displayWeekday ? translate.week : translate.week.capitalize();
    final week = settings.showWeekNumber
        ? '$weekTranslation ${selectedWeekStart.getWeekNumber()}'
        : '';

    if (!settings.showYearAndMonth) {
      return AppBarTitleRows._(
        row1: day,
        row2: week,
        row3MinTextSize: layout.appBar.thirdLineFontSizeMin,
      );
    }

    final selectedWeekEnd = selectedWeekStart.addDays(6);
    if (selectedWeekStart.month == selectedWeekEnd.month) {
      return AppBarTitleRows._(
        row1: day,
        row2: week,
        row3: DateFormat.yMMMM(langCode).format(selectedWeekStart),
        row3MinTextSize: layout.appBar.thirdLineFontSizeMin,
      );
    }
    return AppBarTitleRows._(
      row1: day,
      row2: week,
      row3: '${DateFormat.MMM(langCode).format(selectedWeekStart)}'
          '-${DateFormat.MMM(langCode).format(selectedWeekEnd)}'
          ' ${DateFormat.y(langCode).format(selectedWeekStart)}',
      row3MinTextSize: layout.appBar.thirdLineFontSizeMin,
    );
  }

  factory AppBarTitleRows.month({
    required DateTime currentTime,
    required String langCode,
    required bool showYear,
    required bool showDay,
  }) {
    return AppBarTitleRows._(
      row1: showDay ? DateFormat.EEEE(langCode).format(currentTime) : '',
      row2: DateFormat.MMMM(langCode).format(currentTime),
      row3: showYear ? DateFormat.y(langCode).format(currentTime) : '',
    );
  }
}
