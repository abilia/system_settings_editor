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
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline6,
      overflow: TextOverflow.ellipsis,
      child: Tts(
        data: '${rows.row1};${rows.row2}',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (rows.row1.isNotEmpty) Text(rows.row1),
            if (rows.row2.isNotEmpty) Text(rows.row2),
          ],
        ),
      ),
    );
  }
}

class AppBarTitleRows {
  final String row1, row2;

  const AppBarTitleRows._(this.row1, [this.row2 = '']);
  factory AppBarTitleRows.day({
    bool displayWeekDay = true,
    bool displayPartOfDay = true,
    bool displayDate = true,
    bool compress = true,
    @required DateTime currentTime,
    @required DateTime day,
    @required DayParts dayParts,
    @required String langCode,
    @required Translated translator,
  }) {
    final part = currentTime.dayPart(dayParts);
    final partOfDay =
        _getPartOfDay(currentTime.isAtSameDay(day), part, translator);
    var row1 =
        displayWeekDay ? '${DateFormat('EEEE', langCode).format(day)}' : '';
    var row2 = displayDate
        ? DateFormat(compress ? 'd MMM yy' : 'd MMMM y', langCode).format(day)
        : displayPartOfDay
            ? partOfDay
            : '';
    if (displayDate && displayPartOfDay && partOfDay.isNotEmpty) {
      row1 = displayWeekDay
          ? '${DateFormat(compress ? 'EEE' : 'EEEE', langCode).format(day)}, ${compress ? partOfDay.substring(0, 3) : partOfDay}'
          : partOfDay;
    }
    return AppBarTitleRows._(row1, row2);
  }

  static String _getPartOfDay(
    bool today,
    DayPart part,
    Translated translator,
  ) {
    if (today) {
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

  factory AppBarTitleRows.week({
    @required DateTime currentTime,
    @required DateTime selectedWeekStart,
    @required DateTime selectedDay,
    @required Translated translator,
  }) {
    final shortWeekDayName = translator.shortWeekday(selectedDay.weekday);
    final week = '${translator.week} ${selectedWeekStart.getWeekNumber()}';
    final row1 = selectedDay.isSameWeek(selectedWeekStart) &&
            currentTime.isSameWeek(selectedWeekStart)
        ? ' $shortWeekDayName, $week'
        : week;
    final row2 = '${selectedWeekStart.year}';

    return AppBarTitleRows._(row1, row2);
  }

  factory AppBarTitleRows.month({
    DateTime currentTime,
    String langCode,
  }) =>
      AppBarTitleRows._(DateFormat.yMMMM(langCode).format(currentTime));
}
