import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import 'package:seagull/ui/all.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MonthAppBar(),
      body: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
          final dayThemes = List.generate(
            DateTime.daysPerWeek,
            (d) => weekdayTheme(
              dayColor: memoSettingsState.calendarDayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: d + 1,
            ),
          );
          return Column(
            children: [
              MonthHeading(dayThemes: dayThemes),
              Expanded(
                child: MonthContent(dayThemes: dayThemes),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MonthContent extends StatelessWidget {
  const MonthContent({
    Key key,
    @required this.dayThemes,
  }) : super(key: key);
  final List<DayTheme> dayThemes;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarBloc, MonthCalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            ...state.weeks.map(
              (week) => Expanded(
                child: WeekRow(week, dayThemes: dayThemes),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WeekRow extends StatelessWidget {
  final MonthWeek week;
  const WeekRow(
    this.week, {
    Key key,
    @required this.dayThemes,
  }) : super(key: key);
  final List<DayTheme> dayThemes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.s),
      child: Row(
        children: [
          WeekNumber(weekNumber: week.number),
          ...week.days.map(
            (day) => Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.s),
                  child: day is MonthDay
                      ? MonthDayView(
                          day,
                          dayTheme: dayThemes[day.day.weekday - 1],
                        )
                      : const SizedBox()

                  // MonthDayView(day, dayTheme: dayThemes[day. ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthHeading extends StatelessWidget {
  const MonthHeading({
    Key key,
    @required this.dayThemes,
  }) : super(key: key);
  final List<DayTheme> dayThemes;

  @override
  Widget build(BuildContext context) {
    final dateformat = DateFormat('', '${Localizations.localeOf(context)}');
    final weekdays = dateformat.dateSymbols.STANDALONEWEEKDAYS;
    final weekdaysShort = dateformat.dateSymbols.STANDALONESHORTWEEKDAYS;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const WeekNumber(),
        ...List.generate(DateTime.daysPerWeek, (weekday) {
          final weekdayindex = (weekday + 1) % DateTime.daysPerWeek;
          return Expanded(
            child: Tts(
              data: weekdays[weekdayindex],
              child: Container(
                height: 32.s,
                color: dayThemes[weekday].color,
                child: Center(
                  child: Text(
                    weekdaysShort[weekdayindex],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class MonthDayView extends StatelessWidget {
  final MonthDay day;
  final DayTheme dayTheme;
  const MonthDayView(
    this.day, {
    Key key,
    @required this.dayTheme,
  }) : super(key: key);
  static final radius = Radius.circular(8.s);

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: day.isCurrent
          ? BoxDecoration(
              border: currentActivityBorder,
              borderRadius: BorderRadius.all(radius),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: dayTheme.color,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
              ),
            ),
            height: 24.s,
            padding: EdgeInsets.symmetric(horizontal: 4.s),
            child: DefaultTextStyle(
              style: dayTheme.theme.textTheme.subtitle2,
              child: Row(
                children: [
                  Text('${day.day.day}'),
                  Spacer(),
                  if (day.hasActivities)
                    ColorDot(color: dayTheme.theme.accentColor),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: dayTheme.secondaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: radius,
                  bottomRight: radius,
                ),
                border: day.occasion == Occasion.current
                    ? null
                    : border, // noTopborder,
              ),
              padding: EdgeInsets.fromLTRB(4.s, 6.s, 4.s, 8.s),
              child: Stack(
                children: [
                  if (day.fullDayActivityCount > 1)
                    MonthFullDayStack(
                      numberOfActivities: day.fullDayActivityCount,
                    )
                  else if (day.fullDayActivity != null)
                    MonthActivityContent(
                      activityDay: day.fullDayActivity,
                    ),
                  if (day.occasion == Occasion.past) CrossOver(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekNumber extends StatelessWidget {
  final int weekNumber;
  const WeekNumber({Key key, this.weekNumber}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final weekTranslation = Translator.of(context).translate.week;
    return Tts(
      data: '$weekTranslation ${(weekNumber ?? '')}',
      child: SizedBox(
        width: 24.s,
        child: Text(
          weekNumber?.toString() ?? weekTranslation[0],
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MonthFullDayStack extends StatelessWidget {
  final int numberOfActivities;
  const MonthFullDayStack({
    Key key,
    @required this.numberOfActivities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AbiliaColors.white,
      borderRadius: BorderRadius.all(MonthDayView.radius),
      border: border,
    );
    return Stack(
      children: [
        Container(
          child: Padding(
            padding: EdgeInsets.only(top: 2.s, left: 2.s),
            child: Container(decoration: decoration),
          ),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(bottom: 2.s, right: 2.s),
            child: Container(
              decoration: decoration,
              child: Center(
                child: Text('+$numberOfActivities'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MonthActivityContent extends StatelessWidget {
  const MonthActivityContent({
    Key key,
    @required this.activityDay,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: BorderRadius.all(MonthDayView.radius),
        border: border,
      ),
      child: Center(
        child: activityDay.activity.hasImage
            ? FadeInAbiliaImage(
                imageFileId: activityDay.activity.fileId,
                imageFilePath: activityDay.activity.icon,
                fit: BoxFit.fitWidth,
              )
            : Padding(
                padding: EdgeInsets.all(3.0.s),
                child: Tts(
                  child: Text(
                    activityDay.activity.title,
                  ),
                ),
              ),
      ),
    );
  }
}
