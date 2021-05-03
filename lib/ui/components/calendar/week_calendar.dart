import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

class WeekCalendarTab extends StatelessWidget {
  const WeekCalendarTab({
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
        return Scaffold(
          backgroundColor: AbiliaColors.white,
          appBar: WeekAppBar(
            currentWeekStart: state.currentWeekStart,
            selectedDay: selectedDay,
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(2.s, 4.s, 2.s, 0),
            child: WeekCalendar(
              activities: state.currentWeekActivities,
              selectedDay: selectedDay,
              weekStart: weekStart,
            ),
          ),
        );
      }),
    );
  }
}

class WeekCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime weekStart;
  final Map<int, List<ActivityOccasion>> activities;

  const WeekCalendar({
    Key key,
    @required this.selectedDay,
    @required this.weekStart,
    @required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => Column(
        children: [
          WeekCalendarTop(
            activities: activities,
            selectedDay: selectedDay,
            weekStart: weekStart,
            dayColor: memoSettingsState.calendarDayColor,
            weekDisplayDays: memoSettingsState.weekDisplayDays,
          ),
          Expanded(
              child: WeekCalendarBody(
            activities: activities,
            dayColor: memoSettingsState.calendarDayColor,
            selectedDay: selectedDay,
            weekStart: weekStart,
            weekDisplayDays: memoSettingsState.weekDisplayDays,
            weekColor: memoSettingsState.weekColor,
          )),
        ],
      ),
    );
  }
}

class WeekCalendarTop extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime weekStart;
  final Map<int, List<ActivityOccasion>> activities;
  final DayColor dayColor;
  final WeekDisplayDays weekDisplayDays;
  const WeekCalendarTop({
    Key key,
    @required this.selectedDay,
    @required this.weekStart,
    @required this.activities,
    @required this.dayColor,
    @required this.weekDisplayDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: List<WeekCalendarDayHeading>.generate(
            weekDisplayDays.numberOfDays(), (i) {
          final day = weekStart.addDays(i);
          return WeekCalendarDayHeading(
            day: day,
            selected: day.isAtSameDay(selectedDay),
            fullDayActivities:
                activities[i].where((a) => a.activity.fullDay).toList(),
            dayColor: dayColor,
          );
        }),
      ),
    );
  }
}

class WeekCalendarDayHeading extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final List<ActivityOccasion> fullDayActivities;
  final DayColor dayColor;
  const WeekCalendarDayHeading({
    Key key,
    @required this.day,
    @required this.selected,
    @required this.fullDayActivities,
    @required this.dayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final borderSize = selected ? 2.s : 1.s;
    final weekDayFormat =
        DateFormat('EEEE', Localizations.localeOf(context).toLanguageTag());
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return Flexible(
      flex: selected ? 77 : 45,
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.0.s),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AbiliaColors.red : dayTheme.borderColor,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
              ),
            ),
            child: Container(
              margin: EdgeInsetsDirectional.only(
                  start: borderSize, end: borderSize, top: borderSize),
              decoration: BoxDecoration(
                color: dayTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: innerRadiusFromBorderSize(borderSize),
                  topRight: innerRadiusFromBorderSize(borderSize),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: selected ? 3.s : 4.s,
                  right: 2.s,
                  left: 2.s,
                  bottom: 4.s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 44.s,
                      child: DefaultTextStyle(
                        style: dayTheme.theme.textTheme.bodyText1
                            .copyWith(height: 18 / 16),
                        child: Tts(
                            data: '${day.day}, ${weekDayFormat.format(day)}',
                            child: BlocBuilder<ClockBloc, DateTime>(
                              buildWhen: (previous, current) =>
                                  !previous.isAtSameDay(current),
                              builder: (context, now) => WithCrossOver(
                                color: dayTheme.theme.textTheme.bodyText1.color,
                                crossOverPadding:
                                    EdgeInsets.fromLTRB(4.s, 4.s, 4.s, 12.s),
                                applyCross: day.isBefore(now.onlyDays()),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${day.day}',
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        t.shortWeekday(day.weekday),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ),
                    if (fullDayActivities.length == 1)
                      ...fullDayActivities
                          .map((a) => FullDayActivity(activityOccasion: a))
                    else if (fullDayActivities.length > 1)
                      FullDayStack(
                          numberOfActivities: fullDayActivities.length),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullDayStack extends StatelessWidget {
  final int numberOfActivities;
  const FullDayStack({
    Key key,
    @required this.numberOfActivities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 36.s,
          child: Padding(
            padding: EdgeInsets.only(top: 2.s, left: 2.s),
            child: Container(
              decoration: whiteBoxDecoration,
              width: double.infinity,
            ),
          ),
        ),
        Container(
          height: 36.s,
          child: Padding(
            padding: EdgeInsets.only(bottom: 2.s, right: 2.s),
            child: Container(
              decoration: whiteBoxDecoration,
              width: double.infinity,
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

class WeekCalendarBody extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime weekStart;
  final Map<int, List<ActivityOccasion>> activities;
  final DayColor dayColor;
  final WeekDisplayDays weekDisplayDays;
  final WeekColor weekColor;
  const WeekCalendarBody({
    Key key,
    @required this.selectedDay,
    @required this.weekStart,
    @required this.activities,
    @required this.dayColor,
    @required this.weekDisplayDays,
    @required this.weekColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => ListView(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<WeekDayColumn>.generate(
                    weekDisplayDays.numberOfDays(), (i) {
                  final day = weekStart.addDays(i);
                  return WeekDayColumn(
                    day: day,
                    selected: day.isAtSameDay(selectedDay),
                    activities: activities[i]
                        .where((a) => !a.activity.fullDay)
                        .toList(),
                    dayColor: dayColor,
                    weekColor: weekColor,
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class WeekDayColumn extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final List<ActivityOccasion> activities;
  final DayColor dayColor;
  final WeekColor weekColor;

  const WeekDayColumn({
    Key key,
    @required this.day,
    @required this.selected,
    @required this.activities,
    @required this.dayColor,
    @required this.weekColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderSize = selected ? 2.s : 1.s;
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return Flexible(
      flex: selected ? 77 : 45,
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
          DefaultTabController.of(context).animateTo(0);
        },
        child: Padding(
          padding: EdgeInsets.only(right: 2.s, left: 2.s, bottom: 4.s),
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? AbiliaColors.red
                  : weekColor == WeekColor.columns
                      ? dayTheme.secondaryColor
                      : AbiliaColors.white110,
              borderRadius: BorderRadius.only(
                bottomLeft: radius,
                bottomRight: radius,
              ),
            ),
            child: Container(
              width: double.infinity,
              margin: EdgeInsetsDirectional.only(
                  start: borderSize, end: borderSize, bottom: borderSize),
              decoration: BoxDecoration(
                color: weekColor == WeekColor.columns
                    ? dayTheme.secondaryColor
                    : AbiliaColors.white110,
                borderRadius: BorderRadius.only(
                  bottomLeft: innerRadiusFromBorderSize(borderSize),
                  bottomRight: innerRadiusFromBorderSize(borderSize),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.s, horizontal: 2.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: activities
                      .map((ao) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.s),
                            child: WeekActivity(activityOccasion: ao),
                          ))
                      .toList(),
                ),
              ),
            ),
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
      child: WeekActivityContent(activityOccasion: activityOccasion),
    );
  }
}

class WeekActivityContent extends StatelessWidget {
  const WeekActivityContent({
    Key key,
    @required this.activityOccasion,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
        color: AbiliaColors.white,
      ),
      child: activityOccasion.activity.hasImage
          ? ActivityImage.fromActivityOccasion(
              activityOccasion: activityOccasion,
              size: double.infinity,
              fit: BoxFit.cover,
              crossOverPadding: EdgeInsets.all(7.s))
          : Padding(
              padding: EdgeInsets.all(3.0.s),
              child: ActivityOccasionDecoration(
                activityOccasion: activityOccasion,
                crossOverPadding: EdgeInsets.all(4.s),
                child: Center(
                  child: Tts(
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

class FullDayActivity extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  const FullDayActivity({
    Key key,
    @required this.activityOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.s,
      child: WeekActivityContent(
        activityOccasion: activityOccasion,
      ),
    );
  }
}
