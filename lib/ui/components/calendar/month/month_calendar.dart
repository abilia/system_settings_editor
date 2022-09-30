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
    final dayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    return MonthBody(calendarDayColor: dayColor);
  }
}

class MonthBody extends StatelessWidget {
  const MonthBody({
    required this.calendarDayColor,
    this.showPreview = true,
    Key? key,
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
  const MonthContent({
    required this.dayThemes,
    required this.dayBuilder,
    Key? key,
  }) : super(key: key);

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
    required this.dayThemes,
    required this.builder,
    Key? key,
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
    required this.dayThemes,
    this.showLeadingWeekShort = true,
    Key? key,
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
  final MonthDay monthDay;
  final DayTheme dayTheme;

  const MonthDayView(
    this.monthDay, {
    required this.dayTheme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headingTextStyleCorrectColor =
        (dayTheme.theme.textTheme.subtitle2 ?? subtitle2).copyWith(
      color: monthDay.isPast ? AbiliaColors.black : null,
      height: 1,
      fontSize: layout.monthCalendar.dayHeadingFontSize,
    );

    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(monthDay.day),
      child: GestureDetector(
        onTap: () {
          final currentDay = context.read<DayPickerBloc>().state.day;
          currentDay.isAtSameDay(monthDay.day)
              ? DefaultTabController.of(context)?.animateTo(0)
              : BlocProvider.of<DayPickerBloc>(context)
                  .add(GoTo(day: monthDay.day));
        },
        child: BlocSelector<DayPickerBloc, DayPickerState, DateTime>(
          selector: (state) => state.day,
          builder: (context, pickedDay) {
            final monthWeekColor = context.select(
                (MemoplannerSettingsBloc bloc) =>
                    bloc.state.monthCalendar.monthWeekColor);
            final highlighted =
                (monthDay.isCurrent || pickedDay.isAtSameDay(monthDay.day));
            final borderRadius = BorderRadius.circular(highlighted
                ? layout.monthCalendar.dayRadiusHighlighted
                : layout.monthCalendar.dayRadius);
            final backgroundColor = monthDay.isPast
                ? AbiliaColors.white110
                : monthWeekColor == WeekColor.captions
                    ? AbiliaColors.white
                    : dayTheme.secondaryColor;
            final Border border = monthDay.isCurrent
                ? currentBorder
                : pickedDay.isAtSameDay(monthDay.day)
                    ? selectedActivityBorder
                    : transparentBlackBorder;

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
              foregroundDecoration: BoxDecoration(
                border: border,
                borderRadius: borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: layout.monthCalendar.dayHeaderHeight,
                    decoration: BoxDecoration(
                      color: monthDay.isPast
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
                          Text('${monthDay.day.day}'),
                          const Spacer(),
                          if (monthDay.hasEvent)
                            Padding(
                              padding:
                                  layout.monthCalendar.hasActivitiesDotPadding,
                              child: ColorDot(
                                radius:
                                    layout.monthCalendar.hasActivitiesDotRadius,
                                color: monthDay.isPast
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
                      day: monthDay,
                      highlighted: highlighted,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
                  const CrossOver(
                    style: CrossOverStyle.darkSecondary,
                  ),
              ],
            )
          : null,
    );
  }
}

class MonthDayViewCompact extends StatelessWidget {
  final MonthDay monthDay;
  final DayTheme dayTheme;

  const MonthDayViewCompact(
    this.monthDay, {
    required this.dayTheme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = dayTheme.theme.textTheme.subtitle1 ?? subtitle1;
    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(monthDay.day),
      child: GestureDetector(
        onTap: () {
          final currentDay = context.read<DayPickerBloc>().state.day;
          currentDay.isAtSameDay(monthDay.day)
              ? DefaultTabController.of(context)?.animateTo(0)
              : BlocProvider.of<DayPickerBloc>(context)
                  .add(GoTo(day: monthDay.day));
        },
        child: BlocSelector<DayPickerBloc, DayPickerState, DateTime>(
          selector: (state) => state.day,
          builder: (context, pickedDay) {
            final monthWeekColor = context.select(
                (MemoplannerSettingsBloc bloc) =>
                    bloc.state.monthCalendar.monthWeekColor);
            final dayIsHighlighted =
                (monthDay.isCurrent || pickedDay.isAtSameDay(monthDay.day));

            final borderRadius = BorderRadius.circular(dayIsHighlighted
                ? layout.monthCalendar.dayRadiusHighlighted
                : layout.monthCalendar.dayRadius);

            final dayTextStyle =
                monthDay.isPast || monthWeekColor == WeekColor.captions
                    ? textStyle.copyWith(color: AbiliaColors.black)
                    : textStyle.copyWith(
                        color: dayTheme.monthSurfaceColor,
                      );

            final backgroundColor = monthDay.isPast
                ? AbiliaColors.white110
                : monthWeekColor == WeekColor.captions
                    ? AbiliaColors.white
                    : dayTheme.monthColor;

            return Container(
              foregroundDecoration: monthDay.isCurrent
                  ? BoxDecoration(
                      border: currentBorder,
                      borderRadius: borderRadius,
                    )
                  : BoxDecoration(
                      border: transparentBlackBorder,
                      borderRadius: borderRadius,
                    ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
              padding: dayIsHighlighted
                  ? layout.monthCalendar.dayViewPaddingHighlighted
                  : layout.monthCalendar.dayViewPadding,
              margin: dayIsHighlighted
                  ? layout.monthCalendar.dayViewMarginHighlighted
                  : layout.monthCalendar.dayViewMargin,
              child: DefaultTextStyle(
                style: dayTextStyle,
                child: Stack(
                  children: [
                    Center(child: Text('${monthDay.day.day}')),
                    if (monthDay.hasEvent || monthDay.fullDayActivityCount > 0)
                      Align(
                        alignment: Alignment.topRight,
                        child: ColorDot(
                          radius: layout.monthCalendar.hasActivitiesDotRadius,
                          color: AbiliaColors.black,
                        ),
                      ),
                    if (monthDay.isPast)
                      Padding(
                        padding: layout.monthCalendar.crossOverPadding,
                        child: const CrossOver(
                          style: CrossOverStyle.darkSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
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
    required this.activityDay,
    required this.isPast,
    this.width,
    this.height,
    this.goToActivityOnTap = false,
    Key? key,
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
