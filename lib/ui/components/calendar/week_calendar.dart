import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
        builder: (context, state) {
      final weekStart = state.currentWeekStart;
      return Scaffold(
        appBar: WeekAppBar(
          currentWeekStart: state.currentWeekStart,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 6.0.s,
            vertical: 8.s,
          ),
          child: Row(
            children: [
              WeekColumn(
                active: false,
                activityOccasions: state.as[1],
                color: AbiliaColors.green40,
                day: weekStart,
              ),
              WeekColumn(
                active: false,
                activityOccasions: state.as[2],
                color: AbiliaColors.blue40,
                day: weekStart.copyWith(day: weekStart.day + 1),
              ),
              WeekColumn(
                active: false,
                activityOccasions: state.as[3],
                color: AbiliaColors.white,
                day: weekStart.copyWith(day: weekStart.day + 2),
              ),
              WeekColumn(
                active: true,
                activityOccasions: state.as[4],
                color: AbiliaColors.brown40,
                day: weekStart.copyWith(day: weekStart.day + 3),
              ),
              WeekColumn(
                active: false,
                activityOccasions: state.as[5],
                color: AbiliaColors.yellow40,
                day: weekStart.copyWith(day: weekStart.day + 4),
              ),
              WeekColumn(
                active: false,
                activityOccasions: state.as[6],
                color: AbiliaColors.pink40,
                day: weekStart.copyWith(day: weekStart.day + 5),
              ),
              WeekColumn(
                active: false,
                activityOccasions: state.as[7],
                color: AbiliaColors.red40,
                day: weekStart.copyWith(day: weekStart.day + 6),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class WeekAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime currentWeekStart;

  const WeekAppBar({
    Key key,
    @required this.currentWeekStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now();
    final textStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: AbiliaColors.white);
    return Theme(
      data: bottomNavigationBarTheme,
      child: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0.s,
              vertical: 8.0.s,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ActionButton(
                  onPressed: () => BlocProvider.of<WeekCalendarBloc>(context)
                      .add(PreviousWeek()),
                  child: Icon(
                    AbiliaIcons.return_to_previous_page,
                    size: defaultIconSize,
                  ),
                ),
                Flexible(
                  child: BlocBuilder<ClockBloc, DateTime>(
                    builder: (context, time) => Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: WeekAppBarTitle(
                              selectedWeekStart: currentWeekStart,
                              textStyle: textStyle),
                        ),
                        if (day.isDayBefore(time))
                          CrossOver(color: textStyle.color),
                      ],
                    ),
                  ),
                ),
                ActionButton(
                  onPressed: () => BlocProvider.of<WeekCalendarBloc>(context)
                      .add(NextWeek()),
                  child: Icon(
                    AbiliaIcons.go_to_next_page,
                    size: defaultIconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(68.s);
}

class WeekColumn extends StatelessWidget {
  final bool active;
  final List<ActivityOccasion> activityOccasions;
  final Color color;
  final DateTime day;

  const WeekColumn({
    Key key,
    @required this.active,
    @required this.activityOccasions,
    @required this.color,
    @required this.day,
  }) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Flexible(
      flex: active ? 78 : 45,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: active ? 4.0.s : 1.s),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: active
                ? Border.fromBorderSide(
                    BorderSide(
                      color: AbiliaColors.red,
                      width: 2.s,
                    ),
                  )
                : null,
            color: color,
          ),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                  ),
                  child: Column(
                    children: [
                      Text('${day.day}'),
                      Text(t.shortWeekday(day.weekday))
                    ],
                  )),
              ...activityOccasions
                  .map((ao) => WeekActivity(activityOccasion: ao))
            ],
          ),
        ),
      ),
    );
  }
}

class WeekActivity extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  const WeekActivity({
    Key key,
    @required this.activityOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(3.0.s),
        child: Container(
          decoration: BoxDecoration(
            border: border,
            borderRadius: borderRadius,
            color: AbiliaColors.white,
          ),
          child: Center(
            child: activityOccasion.activity.hasImage
                ? ActivityImage.fromActivityOccasion(
                    activityOccasion: activityOccasion,
                    size: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Padding(
                    padding: EdgeInsets.all(3.0.s),
                    child: Text(
                      activityOccasion.activity.title,
                      overflow: TextOverflow.clip,
                      style: abiliaTextTheme.caption.copyWith(height: 20 / 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class WeekAppBarTitle extends StatelessWidget {
  const WeekAppBarTitle({
    Key key,
    @required this.selectedWeekStart,
    @required this.textStyle,
  }) : super(key: key);

  final DateTime selectedWeekStart;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
      final rows = WeekAppBarTitleRows.fromSettings(
        selectedWeekStart: selectedWeekStart,
        day: selectedWeekStart,
        langCode: Localizations.localeOf(context).toLanguageTag(),
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
                overflow: TextOverflow.ellipsis,
              ),
            if (rows.row2.isNotEmpty)
              Text(
                rows.row2,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );
    });
  }
}

class WeekAppBarTitleRows {
  final String row1;
  final String row2;

  WeekAppBarTitleRows(this.row1, this.row2);

  factory WeekAppBarTitleRows.fromSettings({
    DateTime selectedWeekStart,
    DateTime day,
    String langCode,
    Translated translator,
  }) {
    final week = '${translator.week} ${selectedWeekStart.getWeekNumber()}';
    final row1 = day == null
        ? week
        : ' ${DateFormat('EEEE', langCode).format(day)}, $week';
    final row2 = '${selectedWeekStart.year}';

    return WeekAppBarTitleRows(row1, row2);
  }
}
