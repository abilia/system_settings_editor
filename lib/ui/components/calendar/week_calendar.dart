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
    return BlocBuilder<DayPickerBloc, DayPickerState>(
      builder: (context, dayPickerState) =>
          BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
              builder: (context, state) {
        final weekStart = state.currentWeekStart;
        final selectedDay = dayPickerState.day;
        final weekColumns = List<WeekColumn>.generate(7, (i) {
          final day = weekStart.addDays(i);
          return WeekColumn(
            active: day.isAtSameDay(selectedDay),
            activityOccasions: state.as[i],
            day: day,
          );
        });
        return Scaffold(
          appBar: WeekAppBar(
            currentWeekStart: state.currentWeekStart,
            selectedDay: selectedDay,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 6.0.s,
              vertical: 8.s,
            ),
            child: Row(
              children: [...weekColumns],
            ),
          ),
        );
      }),
    );
  }
}

class WeekAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime currentWeekStart;
  final DateTime selectedDay;

  const WeekAppBar({
    Key key,
    @required this.currentWeekStart,
    @required this.selectedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = DateTime.now();
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => AnimatedTheme(
        data: weekdayTheme(
          dayColor:
              currentWeekStart.getWeekNumber() == selectedDay.getWeekNumber()
                  ? memoSettingsState.calendarDayColor
                  : DayColor.noColors,
          languageCode: Localizations.localeOf(context).languageCode,
          weekday: selectedDay.weekday,
        ).theme,
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
                              textStyle: Theme.of(context).textTheme.headline6,
                              selectedDay: selectedDay,
                            ),
                          ),
                          if (day.isDayBefore(time))
                            CrossOver(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .color),
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(68.s);
}

class WeekColumn extends StatelessWidget {
  final bool active;
  final List<ActivityOccasion> activityOccasions;
  final DateTime day;

  const WeekColumn({
    Key key,
    @required this.active,
    @required this.activityOccasions,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, state) {
      final t = Translator.of(context).translate;
      final dayTheme = weekdayTheme(
        dayColor: state.calendarDayColor,
        languageCode: Localizations.localeOf(context).languageCode,
        weekday: day.weekday,
      );
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
                  : dayTheme.color == AbiliaColors.white
                      ? Border.fromBorderSide(
                          BorderSide(
                            color: AbiliaColors.white140,
                            width: 1.s,
                          ),
                        )
                      : null,
              color: dayTheme.color,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      BlocProvider.of<DayPickerBloc>(context)
                          .add(GoTo(day: day));
                    },
                    child: DefaultTextStyle(
                      style: dayTheme.theme.textTheme.bodyText1
                          .copyWith(height: 18 / 16),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: active ? 3.s : 4.s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${day.day}',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              t.shortWeekday(day.weekday),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      color: dayTheme.secondaryColor,
                      child: Column(
                        children: [
                          ...activityOccasions
                              .map((ao) => WeekActivity(activityOccasion: ao))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
    @required this.selectedDay,
    @required this.textStyle,
  }) : super(key: key);

  final DateTime selectedWeekStart;
  final TextStyle textStyle;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
      final rows = WeekAppBarTitleRows.fromSettings(
        selectedWeekStart: selectedWeekStart,
        selectedDay: selectedDay,
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
    DateTime selectedDay,
    String langCode,
    Translated translator,
  }) {
    final week = '${translator.week} ${selectedWeekStart.getWeekNumber()}';
    final row1 = selectedDay.isSameWeek(selectedWeekStart)
        ? ' ${DateFormat('EEEE', langCode).format(selectedDay)}, $week'
        : week;
    final row2 = '${selectedWeekStart.year}';

    return WeekAppBarTitleRows(row1, row2);
  }
}
