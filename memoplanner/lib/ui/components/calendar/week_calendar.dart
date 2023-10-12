import 'dart:math';

import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class WeekCalendarTab extends CalendarTab {
  const WeekCalendarTab({super.key});

  @override
  PreferredSizeWidget get appBar => const WeekAppBar();

  @override
  Widget floatingActionButton(BuildContext context) => const FloatingActions();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: layout.weekCalendar.bodyPadding,
        child: const WeekCalendar(),
      ),
    );
  }
}

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekCalendarState = context.read<WeekCalendarCubit>().state;
    final pageController = PageController(initialPage: weekCalendarState.index);
    return BlocListener<WeekCalendarCubit, WeekCalendarState>(
      listener: (context, state) async {
        await pageController.animateToPage(
          state.index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
      },
      child: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Builder(
          builder: (context) {
            final currentWeek = context.watch<WeekCalendarCubit>().state;
            final weekDisplayDays = context.select(
                (MemoplannerSettingsBloc bloc) =>
                    bloc.state.weekCalendar.weekDisplayDays);
            final numberOfDays = weekDisplayDays.numberOfDays();

            return WeekCalendarPage(
              numberOfDays: numberOfDays,
              weekDisplayDays: weekDisplayDays,
              isCurrentState: index == currentWeek.index,
            );
          },
        ),
      ),
    );
  }
}

class WeekCalendarPage extends StatelessWidget {
  const WeekCalendarPage({
    required this.numberOfDays,
    required this.weekDisplayDays,
    required this.isCurrentState,
    Key? key,
  }) : super(key: key);

  final int numberOfDays;
  final WeekDisplayDays weekDisplayDays;
  final bool isCurrentState;

  WeekCalendarState getWeekCalendarState(BuildContext context) {
    final weekCalendarCubit = context.watch<WeekCalendarCubit>();
    return isCurrentState
        ? weekCalendarCubit.state
        : weekCalendarCubit.previousState;
  }

  @override
  Widget build(BuildContext context) {
    final weekCalendarState = getWeekCalendarState(context);
    final weekStart = weekCalendarState.currentWeekStart;
    final currentWeekEvents = weekCalendarState.currentWeekEvents;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IntrinsicHeight(
          child: Row(
            children: List<WeekCalendarHeadingContent>.generate(
              numberOfDays,
              (i) => WeekCalendarHeadingContent(
                day: weekStart.addDays(i),
                weekDisplayDays: weekDisplayDays,
                selected: context.select(
                  (DayPickerBloc b) => b.state.day.isAtSameDay(
                    weekStart.addDays(i),
                  ),
                ),
                fullDayActivitiesBuilder: (context) {
                  final weekCalendarState = getWeekCalendarState(context);
                  final fullDayActivities = weekCalendarState.fullDayActivities;
                  final index = weekStart.addDays(i).weekday - 1;
                  return fullDayActivities[index] ?? [];
                },
              ),
            ),
          ),
        ),
        _WeekBodyContentWrapper(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<_WeekdayColumn>.generate(
                numberOfDays,
                (i) => _WeekdayColumn(
                  day: weekStart.addDays(i),
                  weekDisplayDays: weekDisplayDays,
                  occasions:
                      currentWeekEvents[weekStart.addDays(i).weekday - 1] ?? [],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WeekCalendarHeadingContent extends StatelessWidget {
  const WeekCalendarHeadingContent({
    required this.day,
    required this.weekDisplayDays,
    required this.selected,
    required this.fullDayActivitiesBuilder,
    Key? key,
  }) : super(key: key);

  final DateTime day;
  final WeekDisplayDays weekDisplayDays;
  final bool selected;
  final FullDayActivitiesBuilder fullDayActivitiesBuilder;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final occasion = context.select((ClockCubit c) => day.dayOccasion(c.state));
    final dayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    final weekdayFormat = DateFormat(
        'MMMMEEEEd', Localizations.localeOf(context).toLanguageTag());
    final borderColor = occasion.isCurrent
        ? AbiliaColors.red
        : selected
            ? AbiliaColors.black
            : dayTheme.borderColor ?? dayTheme.color;
    final borderWidth = selected || occasion.isCurrent
        ? wLayout.selectedDay.dayColumnBorderWidth
        : wLayout.notSelectedDay.dayColumnBorderWidth;
    final textStyle = (dayTheme.theme.textTheme.bodyLarge ?? bodyLarge)
        .copyWith(height: 18 / 16);
    final innerRadius = Radius.circular(wLayout.columnRadius.x - borderWidth);
    final fullDayPadding =
        wLayout.notSelectedDay.innerDayPadding.horizontal / 2;
    final fullDayActivitiesPadding = EdgeInsets.symmetric(
      horizontal: max(
        fullDayPadding - borderWidth,
        0,
      ),
      vertical: fullDayPadding,
    );
    return Flexible(
      flex: _dayColumnFlex(weekDisplayDays, selected),
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
          if (selected) {
            DefaultTabController.of(context).animateTo(0);
          }
        },
        child: _WeekBorderedColumn(
          borderWidth: borderWidth,
          borderColor: borderColor,
          wLayout: wLayout,
          columnColor: dayTheme.color,
          header: true,
          innerRadius: innerRadius,
          past: occasion.isPast,
          selected: selected,
          child: Column(
            children: [
              Expanded(
                child: Tts.data(
                  data: weekdayFormat.format(day),
                  child: BlocBuilder<ClockCubit, DateTime>(
                    buildWhen: (previous, current) =>
                        !previous.isAtSameDay(current),
                    builder: (context, now) => CrossOver(
                      style: dayTheme.crossOverStyle,
                      applyCross: occasion.isPast,
                      padding: wLayout.crossOverDayHeadingPadding,
                      child: Center(
                        child: Text(
                          '${day.day}\n${Lt.of(context).shortWeekday(day.weekday)}',
                          textAlign: TextAlign.center,
                          style: textStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: fullDayActivitiesPadding,
                  child: _FullDayActivities(
                    day: day,
                    selected: selected,
                    fullDayActivitiesBuilder: fullDayActivitiesBuilder,
                  ),
                ),
              ),
              // special divider on past Wednesday to distinguish between header and body (same color)
              if (occasion.isPast && dayTheme.color == AbiliaColors.white110)
                Divider(
                  color: selected ? dayTheme.borderColor : borderColor,
                  height: borderWidth,
                  endIndent: 0,
                  key: TestKey.whiteColumnDivider,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekBodyContentWrapper extends StatelessWidget {
  final Widget child;

  const _WeekBodyContentWrapper({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              ListView(
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: child,
              ),
            ],
          ),
        ),
      );
}

class _FullDayActivities extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final FullDayActivitiesBuilder fullDayActivitiesBuilder;

  const _FullDayActivities({
    required this.day,
    required this.selected,
    required this.fullDayActivitiesBuilder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullDayActivities = fullDayActivitiesBuilder(context);
    if (fullDayActivities.length > 1) {
      return ClickableFullDayStack(
        fullDayActivitiesBuilder: fullDayActivitiesBuilder,
        numberOfActivities: fullDayActivities.length,
        day: day,
      );
    }
    if (fullDayActivities.length == 1) {
      return _WeekActivityContent(
        activityOccasion: fullDayActivities.first,
        selected: selected,
        fullDay: true,
        maxLines: 2,
      );
    }
    return const SizedBox.shrink();
  }
}

class _WeekdayColumn extends StatelessWidget {
  final DateTime day;
  final WeekDisplayDays weekDisplayDays;
  final List<EventOccasion> occasions;

  const _WeekdayColumn({
    required this.day,
    required this.weekDisplayDays,
    required this.occasions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, DateTime>(
      buildWhen: (previous, current) =>
          previous.isAtSameDay(day) != current.isAtSameDay(day),
      builder: (context, now) {
        final calendarSettings = context
            .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
        final weekColor = context.select((MemoplannerSettingsBloc bloc) =>
            bloc.state.weekCalendar.weekColor);
        final dayPickerState = context.watch<DayPickerBloc>().state;
        final wLayout = layout.weekCalendar;
        final past = day.isBefore(now.onlyDays());
        final selected = day.isAtSameDay(dayPickerState.day);
        final today = now.isAtSameDay(day);
        final borderWidth = selected || today
            ? wLayout.selectedDay.dayColumnBorderWidth
            : wLayout.notSelectedDay.dayColumnBorderWidth;
        final dayTheme = weekdayTheme(
          dayColor: calendarSettings.dayColor,
          languageCode: Localizations.localeOf(context).languageCode,
          weekday: day.weekday,
        );
        final columnColor = past
            ? AbiliaColors.white110
            : weekColor == WeekColor.columns
                ? dayTheme.secondaryColor
                : AbiliaColors.white;
        final borderColor =
            _bodyColumnBorderColor(today, selected, past, columnColor) ??
                dayTheme.borderColor ??
                dayTheme.secondaryColor;

        final tempPadding = selected
            ? wLayout.selectedDay.innerDayPadding
            : wLayout.notSelectedDay.innerDayPadding;
        final innerDayPadding = tempPadding.copyWith(
          left: max(tempPadding.left - borderWidth, 0),
          right: max(tempPadding.right - borderWidth, 0),
        );
        final innerRadius = Radius.circular(
          wLayout.columnRadius.x - borderWidth,
        );

        return Flexible(
          flex: _dayColumnFlex(weekDisplayDays, selected),
          child: GestureDetector(
            onTap: () {
              DefaultTabController.of(context).animateTo(0);
              BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
            },
            child: _WeekBorderedColumn(
              borderWidth: borderWidth,
              borderColor: borderColor,
              wLayout: wLayout,
              columnColor: columnColor,
              header: false,
              innerRadius: innerRadius,
              past: past,
              selected: selected,
              child: Padding(
                padding: innerDayPadding,
                child: _WeekdayColumnItems(
                  day: day,
                  selected: selected,
                  showCategories: calendarSettings.categories.show,
                  showCategoryColor: calendarSettings.categories.showColors,
                  occasions: occasions,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeekdayColumnItems extends StatelessWidget {
  final DateTime day;
  final bool selected, showCategories, showCategoryColor;
  final List<EventOccasion> occasions;

  const _WeekdayColumnItems({
    required this.day,
    required this.selected,
    required this.showCategories,
    required this.showCategoryColor,
    required this.occasions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < occasions.length; i++)
          Padding(
              padding: _categoryPadding(
                showCategories,
                selected,
                occasions[i].category,
                i > 0 && occasions[i - 1].category != occasions[i].category,
              ),
              child: occasions[i] is ActivityOccasion
                  ? _activityWidget(occasions[i] as ActivityOccasion)
                  : _timerWidget(occasions[i] as TimerOccasion)),
      ],
    );
  }

  Widget _activityWidget(ActivityOccasion occasion) {
    return selected && !layout.go
        ? ActivityCard(
            activityOccasion: occasion,
            showCategoryColor: showCategoryColor,
            showInfoIcons: false,
          )
        : AspectRatio(
            aspectRatio: 1,
            child: _WeekActivityContent(
              activityOccasion: occasion,
              selected: selected,
              maxLines: 3,
            ),
          );
  }

  Widget _timerWidget(TimerOccasion occasion) {
    return selected && !layout.go
        ? TimerCard(
            timerOccasion: occasion,
            day: day,
          )
        : _WeekTimerContent(
            timerOccasion: occasion,
            selected: selected,
          );
  }

  EdgeInsets _categoryPadding(
    bool showCategories,
    selected,
    int category,
    bool newCategory,
  ) {
    final spacing = layout.weekCalendar.activityDistance;

    if (!showCategories) {
      return EdgeInsets.symmetric(
        vertical: spacing,
      );
    }
    return EdgeInsets.only(
      top: !layout.go && selected && newCategory ? spacing * 2 : spacing,
      bottom: spacing,
      right: selected && category == Category.left
          ? layout.weekCalendar.categoryInset
          : 0,
      left: selected && category == Category.right
          ? layout.weekCalendar.categoryInset
          : 0,
    );
  }
}

class _WeekActivityContent extends StatelessWidget {
  const _WeekActivityContent({
    required this.activityOccasion,
    required this.selected,
    required this.maxLines,
    this.fullDay = false,
    Key? key,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final bool selected, fullDay;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      activityOccasion.semanticsProperties(context),
      child: _WeekEventContent(
        occasion: activityOccasion,
        selected: selected && !fullDay,
        showColors: !fullDay,
        onClick: () async {
          final authProviders = copiedAuthProviders(context);
          await Navigator.push(
            context,
            ActivityPage.route(
              activityDay: activityOccasion,
              authProviders: authProviders,
            ),
          );
        },
        child: FullDayCalendarImage(
          activityDay: activityOccasion,
          isPast: activityOccasion.isPast,
          fit: selected && fullDay ? BoxFit.scaleDown : BoxFit.cover,
        ),
      ),
    );
  }
}

class _WeekTimerContent extends StatelessWidget {
  const _WeekTimerContent({
    required this.timerOccasion,
    required this.selected,
    Key? key,
  }) : super(key: key);

  final TimerOccasion timerOccasion;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final textStyle = (Theme.of(context).textTheme.bodySmall ?? bodySmall)
        .copyWith(overflow: TextOverflow.ellipsis);

    return Tts.fromSemantics(
      timerOccasion.timer.semanticsProperties(context),
      child: _WeekEventContent(
        occasion: timerOccasion,
        selected: selected,
        onClick: () async {
          final authProviders = copiedAuthProviders(context);
          final day = context.read<DayPickerBloc>().state.day;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: TimerPage(
                  timerOccasion: timerOccasion,
                  day: day,
                ),
              ),
              settings: (TimerPage).routeSetting(),
            ),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: wLayout.timerCard.wheelPadding,
              child: SizedBox.fromSize(
                size: !selected && Config.isMPGO
                    ? wLayout.timerCard.smallWheelSize
                    : wLayout.timerCard.largeWheelSize,
                child: TimerCardWheel(timerOccasion),
              ),
            ),
            if (timerOccasion.timer.hasImage)
              Padding(
                padding: wLayout.timerCard.imagePadding,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: timerOccasion.isPast ? 0.5 : 1.0,
                        child: FadeInAbiliaImage(
                          fit: selected ? BoxFit.scaleDown : BoxFit.cover,
                          imageFileId: timerOccasion.timer.fileId,
                          height: double.infinity,
                          width: double.infinity,
                          borderRadius: BorderRadius.only(
                              topLeft: wLayout.timerCard.borderRadius,
                              topRight: wLayout.timerCard.borderRadius),
                        ),
                      ),
                      if (timerOccasion.isPast)
                        CrossOver(
                          style: CrossOverStyle.darkSecondary,
                          padding:
                              layout.commonCalendar.crossOverActivityPadding,
                        ),
                    ],
                  ),
                ),
              )
            else if (timerOccasion.timer.hasTitle)
              Padding(
                padding: wLayout.timerCard.textPadding,
                child: Text(
                  timerOccasion.timer.title,
                  style: textStyle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: wLayout.timerCard.textPadding,
                child: TimeLeft(timerOccasion, textStyle: textStyle),
              )
          ],
        ),
      ),
    );
  }
}

class _WeekEventContent extends StatelessWidget {
  final EventOccasion occasion;
  final Function()? onClick;
  final bool selected;
  final bool? showColors;
  final Widget child;

  const _WeekEventContent({
    required this.occasion,
    required this.onClick,
    required this.selected,
    required this.child,
    this.showColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final borderRadius = selected
        ? wLayout.selectedDay.activityRadius
        : wLayout.notSelectedDay.activityRadius;
    final bool showColors = this.showColors ??
        context.select((MemoplannerSettingsBloc bloc) =>
            bloc.state.calendar.categories.showColors);
    final categoryBorder = getCategoryBorder(
      inactive: occasion.isPast,
      current: occasion.isCurrent,
      showCategoryColor: showColors,
      category: occasion.category,
      borderWidth: selected
          ? wLayout.selectedDay.activityBorderWidth
          : wLayout.notSelectedDay.activityBorderWidth,
      currentBorderWidth: selected
          ? wLayout.selectedDay.currentActivityBorderWidth
          : wLayout.notSelectedDay.currentActivityBorderWidth,
    );

    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          border: categoryBorder,
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            borderRadius.topRight.x - categoryBorder.left.width,
          ),
          child: Container(
            color: occasion.isPast ? AbiliaColors.white110 : AbiliaColors.white,
            child: child,
          ),
        ),
      ),
    );
  }
}

int _dayColumnFlex(WeekDisplayDays weekDisplayDays, bool selected) {
  switch (weekDisplayDays) {
    case WeekDisplayDays.everyDay:
      return selected
          ? layout.weekCalendar.selectedDay.everyDayFlex
          : layout.weekCalendar.notSelectedDay.everyDayFlex;
    case WeekDisplayDays.weekdays:
      return selected
          ? layout.weekCalendar.selectedDay.weekdaysFlex
          : layout.weekCalendar.notSelectedDay.weekdaysFlex;
  }
}

Color? _bodyColumnBorderColor(
    bool today, bool selected, bool past, Color columnColor) {
  if (today) return AbiliaColors.red;
  if (selected) return AbiliaColors.black;
  if (past) return AbiliaColors.white110;
  if (columnColor == AbiliaColors.white) return AbiliaColors.white120;
  return null;
}

class _WeekBorderedColumn extends StatelessWidget {
  final Widget child;
  final WeekCalendarLayout wLayout;
  final Color borderColor, columnColor;
  final double borderWidth;
  final Radius innerRadius;
  final bool past, header, selected;

  const _WeekBorderedColumn({
    required this.child,
    required this.wLayout,
    required this.borderColor,
    required this.borderWidth,
    required this.columnColor,
    required this.innerRadius,
    required this.past,
    required this.header,
    required this.selected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Radius topRadius = header ? wLayout.columnRadius : Radius.zero;
    final Radius bottomRadius = !header ? wLayout.columnRadius : Radius.zero;
    final Radius topInnerRadius = header ? innerRadius : Radius.zero;
    final Radius bottomInnerRadius = !header ? innerRadius : Radius.zero;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wLayout.dayDistance),
      child: Container(
        height: header ? wLayout.headerHeight : null,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.only(
            topLeft: topRadius,
            topRight: topRadius,
            bottomLeft: bottomRadius,
            bottomRight: bottomRadius,
          ),
        ),
        child: Container(
            width: double.infinity,
            margin: EdgeInsetsDirectional.only(
              start: borderWidth,
              end: borderWidth,
              top: header ? borderWidth : 0.0,
              bottom: header ? 0.0 : borderWidth,
            ),
            decoration: BoxDecoration(
              color: columnColor,
              borderRadius: BorderRadius.only(
                topLeft: topInnerRadius,
                topRight: topInnerRadius,
                bottomLeft: bottomInnerRadius,
                bottomRight: bottomInnerRadius,
              ),
            ),
            child: child),
      ),
    );
  }
}
