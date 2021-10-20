import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

typedef MonthDayWidgetBuilder = Widget Function(
  MonthDay day,
  DayTheme dayTheme,
);

class MonthCalendarTab extends StatelessWidget {
  const MonthCalendarTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MonthAppBar(),
      floatingActionButton: FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: const MonthCalendar(),
    );
  }
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.calendarDayColor != current.calendarDayColor ||
          previous.monthCalendarType != current.monthCalendarType,
      builder: (context, memoSettingsState) => MonthBody(
        calendarDayColor: memoSettingsState.calendarDayColor,
        monthCalendarType: memoSettingsState.monthCalendarType,
      ),
    );
  }
}

class MonthBody extends StatelessWidget {
  const MonthBody({
    Key? key,
    required this.calendarDayColor,
    required this.monthCalendarType,
  }) : super(key: key);

  final DayColor calendarDayColor;
  final MonthCalendarType monthCalendarType;

  @override
  Widget build(BuildContext context) {
    final dayThemes = List.generate(
      DateTime.daysPerWeek,
      (d) => weekdayTheme(
        dayColor: calendarDayColor,
        languageCode: Localizations.localeOf(context).languageCode,
        weekday: d + 1,
      ),
    );
    final dayBuilder = monthCalendarType == MonthCalendarType.grid
        ? (day, dayTheme) => MonthDayView(day, dayTheme: dayTheme)
        : (day, dayTheme) => MonthDayViewCompact(day, dayTheme: dayTheme);
    return Column(
      children: [
        MonthHeading(dayThemes: dayThemes),
        Expanded(
          flex: 256,
          child: MonthContent(
            dayThemes: dayThemes,
            dayBuilder: dayBuilder,
          ),
        ),
        if (monthCalendarType == MonthCalendarType.preview)
          Expanded(
            flex: 168,
            child: MonthListPreview(dayThemes: dayThemes),
          ),
      ],
    );
  }
}

class MonthContent extends StatelessWidget {
  const MonthContent(
      {Key? key, required this.dayThemes, required this.dayBuilder})
      : super(key: key);

  final MonthDayWidgetBuilder dayBuilder;
  final List<DayTheme> dayThemes;

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(
        initialPage: context.read<MonthCalendarBloc>().state.index);
    return BlocListener<MonthCalendarBloc, MonthCalendarState>(
      listener: (context, state) {
        pageController.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemBuilder: (context, item) {
          return BlocBuilder<MonthCalendarBloc, MonthCalendarState>(
            buildWhen: (oldState, newState) => newState.index == item,
            builder: (context, state) {
              if (state.index != item) return Container();
              return Column(
                children: [
                  ...state.weeks.map(
                    (week) => Expanded(
                      child: week.inMonth
                          ? WeekRow(
                              week,
                              dayThemes: dayThemes,
                              builder: dayBuilder,
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class WeekRow extends StatelessWidget {
  final MonthWeek week;
  final MonthDayWidgetBuilder builder;

  const WeekRow(
    this.week, {
    Key? key,
    required this.dayThemes,
    required this.builder,
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
                    ? builder(day, dayThemes[day.day.weekday - 1])
                    : const SizedBox.shrink(),
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
    Key? key,
    required this.dayThemes,
    this.showLeadingWeekShort = true,
  }) : super(key: key);
  final List<DayTheme> dayThemes;
  final bool showLeadingWeekShort;

  @override
  Widget build(BuildContext context) {
    final dateformat = DateFormat('', '${Localizations.localeOf(context)}');
    final weekdays = dateformat.dateSymbols.STANDALONEWEEKDAYS;
    final weekdaysShort = dateformat.dateSymbols.STANDALONESHORTWEEKDAYS;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (showLeadingWeekShort) const WeekNumber(),
        ...List.generate(DateTime.daysPerWeek, (weekday) {
          final weekdayindex = (weekday + 1) % DateTime.daysPerWeek;
          final dayTheme = dayThemes[weekday];
          final textTheme = dayTheme.theme.textTheme;
          return DefaultTextStyle(
            style: (textTheme.button ?? button).copyWith(
              color: dayTheme.isColor
                  ? textTheme.subtitle2?.color
                  : AbiliaColors.black,
            ),
            child: Expanded(
              child: Tts.data(
                data: weekdays[weekdayindex],
                child: Container(
                  height: 32.s,
                  color: dayTheme.dayColor,
                  child: Center(
                    child: Text(
                      weekdaysShort[weekdayindex],
                      textAlign: TextAlign.center,
                    ),
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
    Key? key,
    required this.dayTheme,
  }) : super(key: key);
  static final monthDayRadius = Radius.circular(8.s);
  static final monthDayborderRadius = BorderRadius.all(monthDayRadius);

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(day.day),
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day.day));
          DefaultTabController.of(context)?.animateTo(0);
        },
        child: BlocBuilder<DayPickerBloc, DayPickerState>(
          builder: (context, dayPickerState) => Container(
            foregroundDecoration: day.isCurrent
                ? BoxDecoration(
                    border: currentBorder,
                    borderRadius: monthDayborderRadius,
                  )
                : dayPickerState.day.isAtSameDay(day.day)
                    ? BoxDecoration(
                        border: selectedActivityBorder,
                        borderRadius: monthDayborderRadius,
                      )
                    : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: dayTheme.color,
                    borderRadius: BorderRadius.vertical(top: monthDayRadius),
                  ),
                  height: 24.s,
                  padding: EdgeInsets.symmetric(horizontal: 4.s),
                  child: DefaultTextStyle(
                    style: dayTheme.theme.textTheme.subtitle2!,
                    child: Row(
                      children: [
                        Text('${day.day.day}'),
                        Spacer(),
                        if (day.hasActivities)
                          ColorDot(color: dayTheme.theme.colorScheme.onSurface),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<MemoplannerSettingBloc,
                      MemoplannerSettingsState>(
                    buildWhen: (previous, current) =>
                        previous.monthWeekColor != current.monthWeekColor,
                    builder: (context, settingState) => MonthDayContainer(
                      color: settingState.monthWeekColor == WeekColor.columns
                          ? dayTheme.secondaryColor
                          : AbiliaColors.white110,
                      day: day,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MonthDayContainer extends StatelessWidget {
  static final bottomRadius =
      BorderRadius.vertical(bottom: MonthDayView.monthDayRadius);

  const MonthDayContainer({
    Key? key,
    required this.color,
    this.day,
  }) : super(key: key);

  final Color color;
  final MonthDay? day;

  @override
  Widget build(BuildContext context) {
    final d = day;
    // A borderRadius can only be given for a uniform Border.
    // https://github.com/flutter/flutter/issues/12583
    // So work around is wrapping containers with
    // background color
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: bottomRadius,
      ),
      child: Container(
        padding: EdgeInsets.only(left: 1.s, right: 1.s, bottom: 1.s),
        decoration: BoxDecoration(
          color: AbiliaColors.transparentBlack30,
          borderRadius: bottomRadius,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(4.s, 6.s, 4.s, 8.s),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(7.s),
              )),
          child: d != null
              ? Stack(
                  children: [
                    if (d.fullDayActivityCount > 1)
                      FullDayStack(
                        numberOfActivities: d.fullDayActivityCount,
                      )
                    else if (d.fullDayActivity != null)
                      MonthActivityContent(
                        activityDay: d.fullDayActivity!,
                      ),
                    if (d.isPast) CrossOver(),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}

class WeekNumber extends StatelessWidget {
  final int? weekNumber;

  const WeekNumber({Key? key, this.weekNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekTranslation = Translator.of(context).translate.week;
    return Tts.data(
      data: '$weekTranslation ${weekNumber ?? ''}',
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

class MonthActivityContent extends StatelessWidget {
  const MonthActivityContent({
    Key? key,
    required this.activityDay,
    this.width,
    this.height,
  }) : super(key: key);

  final ActivityDay activityDay;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      foregroundDecoration: BoxDecoration(
        borderRadius: MonthDayView.monthDayborderRadius,
        border: border,
      ),
      decoration: BoxDecoration(
        borderRadius: MonthDayView.monthDayborderRadius,
        color: AbiliaColors.white,
      ),
      child: Center(
        child: activityDay.activity.hasImage
            ? FadeInAbiliaImage(
                imageFileId: activityDay.activity.fileId,
                imageFilePath: activityDay.activity.icon,
                borderRadius: BorderRadius.zero,
                height: double.infinity,
                width: double.infinity,
              )
            : Padding(
                padding: EdgeInsets.all(3.0.s),
                child: Tts(
                  child: Text(
                    activityDay.activity.title,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
      ),
    );
  }
}
