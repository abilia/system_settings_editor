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
    return const Scaffold(
      appBar: MonthAppBar(),
      floatingActionButton: FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: MonthCalendar(),
    );
  }
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.calendarDayColor != current.calendarDayColor,
      builder: (context, memoSettingsState) => MonthBody(
        calendarDayColor: memoSettingsState.calendarDayColor,
      ),
    );
  }
}

class MonthBody extends StatelessWidget {
  const MonthBody({
    Key? key,
    required this.calendarDayColor,
    this.showPreview = true,
  }) : super(key: key);

  final DayColor calendarDayColor;
  final bool showPreview;

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
    final dayBuilder = Config.isMPGO
        ? (day, dayTheme) => MonthDayViewCompact(
              day,
              dayTheme: dayTheme,
              key: TestKey.monthCalendarDay,
            )
        : (day, dayTheme) => MonthDayView(
              day,
              dayTheme: dayTheme,
              key: TestKey.monthCalendarDay,
            );
    return Column(
      children: [
        MonthHeading(dayThemes: dayThemes),
        Expanded(
          flex: layout.monthCalendar.monthContentFlex,
          child: MonthContent(
            dayThemes: dayThemes,
            dayBuilder: dayBuilder,
          ),
        ),
        if (showPreview)
          Expanded(
            flex: layout.monthCalendar.monthListPreviewFlex,
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
        initialPage: context.read<MonthCalendarCubit>().state.index);
    return BlocListener<MonthCalendarCubit, MonthCalendarState>(
      listener: (context, state) {
        pageController.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemBuilder: (context, item) {
          return BlocBuilder<MonthCalendarCubit, MonthCalendarState>(
            buildWhen: (oldState, newState) => newState.index == item,
            builder: (context, state) {
              if (state.index != item) return Container();
              return Column(
                children: [
                  SizedBox(
                    height: layout.monthCalendar.dayViewMargin.top,
                  ),
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
    return Row(
      children: [
        WeekNumber(weekNumber: week.number),
        ...week.days.map(
          (day) => Expanded(
            child: day is MonthDay
                ? builder(day, dayThemes[day.day.weekday - 1])
                : const SizedBox.shrink(),
          ),
        ),
      ],
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
                  height: layout.monthCalendar.monthHeadingHeight,
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

  @override
  Widget build(BuildContext context) {
    final headingTextStyleCorrectColor =
        (dayTheme.theme.textTheme.subtitle2 ?? subtitle2).copyWith(
      color: day.isPast ? AbiliaColors.black : null,
      height: 1,
      fontSize: layout.monthCalendar.dayHeadingFontSize,
    );

    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(day.day),
      child: GestureDetector(
        onTap: () {
          final currentDay = context.read<DayPickerBloc>().state.day;
          currentDay.isAtSameDay(day.day)
              ? DefaultTabController.of(context)?.animateTo(0)
              : BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day.day));
        },
        child: BlocBuilder<DayPickerBloc, DayPickerState>(
            builder: (context, dayPickerState) {
          return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
              buildWhen: (previous, current) =>
                  previous.monthWeekColor != current.monthWeekColor,
              builder: (context, settingState) {
                final highlighted =
                    (day.isCurrent || dayPickerState.day.isAtSameDay(day.day));
                final borderRadius = BorderRadius.circular(highlighted
                    ? layout.monthCalendar.dayRadiusHighlighted
                    : layout.monthCalendar.dayRadius);

                final backgroundColor = day.isPast
                    ? AbiliaColors.white110
                    : settingState.monthWeekColor == WeekColor.captions
                        ? AbiliaColors.white
                        : dayTheme.secondaryColor;

                return Container(
                  key: TestKey.monthCalendarDayBackgroundColor,
                  margin: highlighted
                      ? layout.monthCalendar.dayViewMarginHighlighted
                      : layout.monthCalendar.dayViewMargin,
                  padding: EdgeInsets.all(highlighted
                      ? layout.monthCalendar.dayBorderWidthHighlighted / 2
                      : 0),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: borderRadius,
                  ),
                  foregroundDecoration: day.isCurrent
                      ? BoxDecoration(
                          border: currentBorder,
                          borderRadius: borderRadius,
                        )
                      : dayPickerState.day.isAtSameDay(day.day)
                          ? BoxDecoration(
                              border: selectedActivityBorder,
                              borderRadius: borderRadius,
                            )
                          : BoxDecoration(
                              border: transparentBlackBorder,
                              borderRadius: borderRadius,
                            ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: layout.monthCalendar.dayHeaderHeight,
                        decoration: BoxDecoration(
                          color: day.isPast
                              ? AbiliaColors.white140
                              : dayTheme.color,
                          borderRadius:
                              BorderRadius.vertical(top: borderRadius.topRight),
                        ),
                        padding: layout.monthCalendar.dayHeaderPadding,
                        child: DefaultTextStyle(
                          style: headingTextStyleCorrectColor,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${day.day.day}'),
                              const Spacer(),
                              if (day.hasActivities)
                                Padding(
                                  padding: layout
                                      .monthCalendar.hasActivitiesDotPadding,
                                  child: ColorDot(
                                    radius: layout
                                        .monthCalendar.hasActivitiesDotRadius,
                                    color: day.isPast
                                        ? AbiliaColors.black
                                        : dayTheme.theme.colorScheme.onSurface,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: MonthDayContainer(
                          day: day,
                          highlighted: highlighted,
                        ),
                      ),
                    ],
                  ),
                );
              });
        }),
      ),
    );
  }
}

class MonthDayContainer extends StatelessWidget {
  const MonthDayContainer({
    Key? key,
    this.day,
    this.highlighted = false,
  }) : super(key: key);

  final MonthDay? day;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final d = day;

    return Container(
      padding: layout.monthCalendar.dayContainerPadding,
      child: d != null
          ? Stack(
              children: [
                if (d.fullDayActivityCount > 1)
                  FullDayStack(
                    key: TestKey.monthCalendarFullDayStack,
                    numberOfActivities: d.fullDayActivityCount,
                  )
                else if (d.fullDayActivity != null)
                  MonthActivityContent(
                    activityDay: d.fullDayActivity!,
                    isPast: d.isPast,
                  ),
                if (d.isPast)
                  CrossOver(
                    strokeWidth: layout.eventCard.crossOverStrokeWidth,
                    color: AbiliaColors.transparentBlack30,
                  ),
              ],
            )
          : null,
    );
  }
}

class MonthDayViewCompact extends StatelessWidget {
  final MonthDay day;
  final DayTheme dayTheme;

  const MonthDayViewCompact(
    this.day, {
    Key? key,
    required this.dayTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = dayTheme.theme.textTheme.subtitle1 ?? subtitle1;
    final textWithCorrectColor = day.isPast
        ? textStyle.copyWith(color: AbiliaColors.black)
        : textStyle.copyWith(
            color: dayTheme.monthSurfaceColor,
          );
    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(day.day),
      child: GestureDetector(
        onTap: () {
          final currentDay = context.read<DayPickerBloc>().state.day;
          currentDay.isAtSameDay(day.day)
              ? DefaultTabController.of(context)?.animateTo(0)
              : BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day.day));
        },
        child: BlocBuilder<DayPickerBloc, DayPickerState>(
            builder: (context, dayPickerState) {
          final dayIsHighlighted =
              (day.isCurrent || dayPickerState.day.isAtSameDay(day.day));
          final borderRadius = BorderRadius.circular(dayIsHighlighted
              ? layout.monthCalendar.dayRadiusHighlighted
              : layout.monthCalendar.dayRadius);

          return Container(
            foregroundDecoration: day.isCurrent
                ? BoxDecoration(
                    border: currentBorder,
                    borderRadius: borderRadius,
                  )
                : dayPickerState.day.isAtSameDay(day.day)
                    ? BoxDecoration(
                        border: selectedActivityBorder,
                        borderRadius: borderRadius,
                      )
                    : BoxDecoration(
                        border: transparentBlackBorder,
                        borderRadius: borderRadius,
                      ),
            decoration: BoxDecoration(
              color: day.isPast ? AbiliaColors.white110 : dayTheme.monthColor,
              borderRadius: borderRadius,
            ),
            padding: dayIsHighlighted
                ? layout.monthCalendar.dayViewPaddingHighlighted
                : layout.monthCalendar.dayViewPadding,
            margin: dayIsHighlighted
                ? layout.monthCalendar.dayViewMarginHighlighted
                : layout.monthCalendar.dayViewMargin,
            child: DefaultTextStyle(
              style: textWithCorrectColor,
              child: Stack(
                children: [
                  Center(child: Text('${day.day.day}')),
                  if (day.hasActivities)
                    Align(
                      alignment: Alignment.topRight,
                      child: ColorDot(
                        radius: layout.monthCalendar.hasActivitiesDotRadius,
                        color: AbiliaColors.black,
                      ),
                    ),
                  if (day.isPast)
                    Padding(
                      padding: layout.monthCalendar.crossOverPadding,
                      child: const CrossOver(
                        color: AbiliaColors.transparentBlack30,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
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
        width: layout.monthCalendar.weekNumberWidth,
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
    required this.isPast,
    this.width,
    this.height,
    this.goToActivityOnTap = false,
  }) : super(key: key);

  final ActivityDay activityDay;
  final double? width;
  final double? height;
  final bool goToActivityOnTap;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.monthCalendar.dayRadius),
        border: border,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.monthCalendar.dayRadius),
        color: AbiliaColors.white,
      ),
      child: Center(
        child: activityDay.activity.hasImage
            ? AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: isPast ? 0.5 : 1.0,
                child: FadeInAbiliaImage(
                  imageFileId: activityDay.activity.fileId,
                  imageFilePath: activityDay.activity.icon,
                  borderRadius: BorderRadius.zero,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              )
            : Padding(
                padding: layout.monthCalendar.activityTextContentPadding,
                child: Tts(
                  child: Text(
                    activityDay.activity.title,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: abiliaTextTheme.caption?.copyWith(
                      fontSize: layout.monthCalendar.fullDayActivityFontSize,
                    ),
                  ),
                ),
              ),
      ),
    );

    if (goToActivityOnTap) {
      return GestureDetector(
        onTap: () async {
          final authProviders = copiedAuthProviders(context);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: ActivityPage(
                  activityDay: activityDay,
                ),
              ),
              settings: RouteSettings(name: 'ActivityPage $activityDay'),
            ),
          );
        },
        child: body,
      );
    } else {
      return body;
    }
  }
}
