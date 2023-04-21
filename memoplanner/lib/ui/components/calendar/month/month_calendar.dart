import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class MonthCalendarTab extends StatelessWidget {
  const MonthCalendarTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthCalendarState = context.watch<MonthCalendarCubit>().state;
    final dayPickerState = context.watch<DayPickerBloc>().state;
    final isCollapsed =
        context.select((MonthCalendarCubit cubit) => cubit.state.isCollapsed);
    final showPreview =
        monthCalendarState.firstDay.month == dayPickerState.day.month &&
            monthCalendarState.firstDay.year == dayPickerState.day.year;
    return Scaffold(
      appBar: const MonthAppBar(),
      floatingActionButton:
          FloatingActions(useBottomPadding: isCollapsed && showPreview),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: MonthCalendar(
        usePreview: true,
        showPreview: showPreview,
        isCollapsed: isCollapsed,
      ),
    );
  }
}

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    this.usePreview = false,
    this.showPreview = false,
    this.isCollapsed = false,
    super.key,
  });

  final bool isCollapsed;
  final bool usePreview;
  final bool showPreview;

  @override
  Widget build(BuildContext context) {
    final calendarDayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);

    final dayThemes = List.generate(
      DateTime.daysPerWeek,
      (d) => weekdayTheme(
        dayColor: calendarDayColor,
        languageCode: Localizations.localeOf(context).languageCode,
        weekday: d + 1,
      ),
    );
    return Column(
      children: [
        MonthHeading(dayThemes: dayThemes),
        Expanded(
          child: MonthContent(
            dayThemes: dayThemes,
            usePreview: usePreview,
            showPreview: showPreview,
            isCollapsed: isCollapsed,
          ),
        ),
      ],
    );
  }
}

class MonthContent extends StatelessWidget {
  final List<DayTheme> dayThemes;
  final bool usePreview;
  final bool showPreview;
  final bool isCollapsed;

  const MonthContent({
    required this.dayThemes,
    required this.usePreview,
    required this.showPreview,
    required this.isCollapsed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(
        initialPage: context.read<MonthCalendarCubit>().state.index);
    final weekBuilder = usePreview && !isCollapsed && showPreview
        ? (MonthWeek week) => SizedBox(
              height: layout.monthCalendar.weekHeight,
              child: WeekRow(
                week,
                dayThemes: dayThemes,
                showPreview: showPreview,
              ),
            )
        : (MonthWeek week) => Expanded(
              child: WeekRow(
                week,
                dayThemes: dayThemes,
                showPreview: showPreview,
              ),
            );

    return BlocListener<MonthCalendarCubit, MonthCalendarState>(
      listener: (context, state) async => pageController.animateToPage(
          state.index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad),
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemBuilder: (context, item) =>
            BlocBuilder<MonthCalendarCubit, MonthCalendarState>(
          buildWhen: (oldState, newState) => newState.index == item,
          builder: (context, state) {
            if (state.index != item) return Container();
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...state.weeks.map(weekBuilder),
                if (usePreview)
                  if (state.isCollapsed) ...[
                    const Spacer(),
                    MonthListPreview(
                      dayThemes: dayThemes,
                      isCollapsed: isCollapsed,
                      showPreview: showPreview,
                    ),
                  ] else
                    Expanded(
                      child: MonthListPreview(
                        dayThemes: dayThemes,
                        isCollapsed: isCollapsed,
                        showPreview: showPreview,
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WeekRow extends StatelessWidget {
  final MonthWeek week;
  final List<DayTheme> dayThemes;
  final bool showPreview;

  const WeekRow(
    this.week, {
    required this.dayThemes,
    required this.showPreview,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCollapsed =
        context.select((MonthCalendarCubit cubit) => cubit.state.isCollapsed);
    final dayBuilder = layout.go && !isCollapsed && showPreview
        ? (MonthDay day, DayTheme dayTheme) => MonthDayViewCompact(
              day,
              dayTheme: dayTheme,
              key: TestKey.monthCalendarDay,
            )
        : (MonthDay day, DayTheme dayTheme) => MonthDayView(
              day,
              dayTheme: dayTheme,
              key: TestKey.monthCalendarDay,
            );
    return Row(
      children: [
        WeekNumber(weekNumber: week.number),
        ...week.days.map(
          (day) => Expanded(
            child: day is MonthDay
                ? dayBuilder(day, dayThemes[day.day.weekday - 1])
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
    final dateFormat = DateFormat('', '${Localizations.localeOf(context)}');
    final weekdays = dateFormat.dateSymbols.STANDALONEWEEKDAYS;
    final weekdaysShort = dateFormat.dateSymbols.STANDALONESHORTWEEKDAYS;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (showLeadingWeekShort) const WeekNumber(),
        ...List.generate(
          DateTime.daysPerWeek,
          (weekday) {
            final weekdayIndex = (weekday + 1) % DateTime.daysPerWeek;
            final dayTheme = dayThemes[weekday];
            final textTheme = dayTheme.theme.textTheme;
            return DefaultTextStyle(
              style: (textTheme.labelLarge ?? labelLarge).copyWith(
                color: dayTheme.isColor
                    ? textTheme.titleSmall?.color
                    : AbiliaColors.black,
              ),
              child: Expanded(
                child: Tts.data(
                  data: weekdays[weekdayIndex],
                  child: Container(
                    height: layout.monthCalendar.headingHeight,
                    color: dayTheme.dayColor,
                    child: Center(
                      child: Text(
                        weekdaysShort[weekdayIndex],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
        (dayTheme.theme.textTheme.titleSmall ?? titleSmall).copyWith(
      color: monthDay.isPast ? AbiliaColors.black : null,
      height: 1,
      fontSize: layout.monthCalendar.day.headingFontSize,
    );

    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(monthDay.day),
      child: GestureDetector(
        onTap: () {
          final currentDay = context.read<DayPickerBloc>().state.day;
          currentDay.isAtSameDay(monthDay.day)
              ? DefaultTabController.of(context).animateTo(0)
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
                ? layout.monthCalendar.day.radiusHighlighted
                : layout.monthCalendar.day.radius);
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
                  ? layout.monthCalendar.day.viewMarginHighlighted
                  : layout.monthCalendar.day.viewMargin,
              padding: EdgeInsets.all(highlighted
                  ? layout.monthCalendar.day.borderWidthHighlighted / 2
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
                    height: layout.monthCalendar.day.headerHeight,
                    decoration: BoxDecoration(
                      color: monthDay.isPast
                          ? AbiliaColors.white140
                          : dayTheme.color,
                      borderRadius:
                          BorderRadius.vertical(top: borderRadius.topRight),
                    ),
                    padding: layout.monthCalendar.day.headerPadding,
                    child: DefaultTextStyle(
                      style: headingTextStyleCorrectColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${monthDay.day.day}'),
                          const Spacer(),
                          if (monthDay.hasEvent)
                            Padding(
                              padding: layout
                                  .monthCalendar.day.hasActivitiesDotPadding,
                              child: ColorDot(
                                radius: layout
                                    .monthCalendar.day.hasActivitiesDotRadius,
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
      padding: layout.monthCalendar.day.containerPadding,
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
    final textStyle = dayTheme.theme.textTheme.bodyMedium ?? titleMedium;
    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(monthDay.day),
      child: GestureDetector(
        onTap: () {
          final currentDay = context.read<DayPickerBloc>().state.day;
          currentDay.isAtSameDay(monthDay.day)
              ? DefaultTabController.of(context).animateTo(0)
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
                ? layout.monthCalendar.day.radiusHighlighted
                : layout.monthCalendar.day.radius);

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
            final Border border = monthDay.isCurrent
                ? currentBorder
                : pickedDay.isAtSameDay(monthDay.day)
                    ? selectedActivityBorder
                    : transparentBlackBorder;

            return Container(
              foregroundDecoration: BoxDecoration(
                border: border,
                borderRadius: borderRadius,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
              padding: dayIsHighlighted
                  ? layout.monthCalendar.day.viewPaddingHighlighted
                  : layout.monthCalendar.day.viewPadding,
              margin: dayIsHighlighted
                  ? layout.monthCalendar.day.viewMarginHighlighted
                  : layout.monthCalendar.day.viewMargin,
              child: DefaultTextStyle(
                style: dayTextStyle,
                child: Stack(
                  children: [
                    Center(child: Text('${monthDay.day.day}')),
                    if (monthDay.hasEvent || monthDay.fullDayActivityCount > 0)
                      Align(
                        alignment: Alignment.topRight,
                        child: ColorDot(
                          radius:
                              layout.monthCalendar.day.hasActivitiesDotRadius,
                          color: AbiliaColors.black,
                        ),
                      ),
                    if (monthDay.isPast)
                      Padding(
                        padding: layout.monthCalendar.day.crossOverPadding,
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
        borderRadius: BorderRadius.circular(layout.monthCalendar.day.radius),
        border: border,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.monthCalendar.day.radius),
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
                padding: layout.monthCalendar.day.activityTextContentPadding,
                child: EllipsesText(
                  activityDay.activity.title,
                  tts: true,
                  maxLines: 3,
                  style: abiliaTextTheme.bodyMedium?.copyWith(
                    fontSize: layout.monthCalendar.day.fullDayActivityFontSize,
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
            ActivityPage.route(
              activityDay: activityDay,
              authProviders: authProviders,
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
