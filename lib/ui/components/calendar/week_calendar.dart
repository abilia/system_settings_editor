import 'dart:math';

import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekCalendarTab extends StatelessWidget {
  const WeekCalendarTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbiliaColors.white,
      appBar: const WeekAppBar(),
      floatingActionButton: const FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Padding(
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
    final pageController = PageController(
      initialPage: context.read<WeekCalendarCubit>().state.index,
    );
    return BlocListener<WeekCalendarCubit, WeekCalendarState>(
      listener: (context, state) {
        pageController.animateToPage(
          state.index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
      },
      child: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, item) =>
            BlocBuilder<WeekCalendarCubit, WeekCalendarState>(
          buildWhen: (previous, current) =>
              current.index == item ||
              previous.currentWeekStart != current.currentWeekStart,
          builder: (context, weekState) {
            if (weekState.index != item) return Container();
            return BlocBuilder<MemoplannerSettingBloc,
                MemoplannerSettingsState>(
              buildWhen: (previous, current) =>
                  previous.weekDisplayDays != current.weekDisplayDays ||
                  previous.settings.calendar.dayColor !=
                      current.settings.calendar.dayColor ||
                  previous.weekColor != current.weekColor,
              builder: (context, memosettings) {
                final numberOfDays =
                    memosettings.weekDisplayDays.numberOfDays();
                final DateTime weekStart = weekState.currentWeekStart;
                final weekDisplayDays =
                    context.select<MemoplannerSettingBloc, WeekDisplayDays>(
                        (bloc) => bloc.state.weekDisplayDays);
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: List<WeekCalenderHeadingContent>.generate(
                          numberOfDays,
                          (i) => WeekCalenderHeadingContent(
                            day: weekStart.addDays(i),
                            weekDisplayDays: weekDisplayDays,
                            selected: context.select<DayPickerBloc, bool>(
                              (bloc) => bloc.state.day.isAtSameDay(
                                weekStart.addDays(i),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _WeekBodyContentWrapper(
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<_WeekDayColumn>.generate(
                            numberOfDays,
                            (i) => _WeekDayColumn(
                              day: weekStart.addDays(i),
                              weekDisplayDays: weekDisplayDays,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class WeekCalenderHeadingContent extends StatelessWidget {
  const WeekCalenderHeadingContent({
    required this.day,
    required this.weekDisplayDays,
    required this.selected,
    Key? key,
  }) : super(key: key);

  final DateTime day;
  final WeekDisplayDays weekDisplayDays;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final occasion =
        context.select((ClockBloc clock) => day.dayOccasion(clock.state));
    final dayColor = context.select<MemoplannerSettingBloc, DayColor>(
        (bloc) => bloc.state.settings.calendar.dayColor);
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    final weekDayFormat = DateFormat(
        'MMMMEEEEd', Localizations.localeOf(context).toLanguageTag());
    final borderColor = occasion.isCurrent
        ? AbiliaColors.red
        : selected
            ? AbiliaColors.black
            : dayTheme.borderColor ?? dayTheme.color;
    final borderWidth = selected || occasion.isCurrent
        ? wLayout.selectedDay.dayColumnBorderWidth
        : wLayout.notSelectedDay.dayColumnBorderWidth;
    final textStyle = (dayTheme.theme.textTheme.bodyText1 ?? bodyText1)
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
          if (selected) {
            DefaultTabController.of(context)?.animateTo(0);
          } else {
            BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
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
                  data: weekDayFormat.format(day),
                  child: BlocBuilder<ClockBloc, DateTime>(
                    buildWhen: (previous, current) =>
                        !previous.isAtSameDay(current),
                    builder: (context, now) => CrossOver(
                      style: dayTheme.crossOverStyle,
                      applyCross: occasion.isPast,
                      padding: wLayout.crossOverDayHeadingPadding,
                      child: Center(
                        child: Text(
                          '${day.day}\n${Translator.of(context).translate.shortWeekday(day.weekday)}',
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
                  ),
                ),
              ),
              // special divider on past Wednesday to distinguish between header and body (same color)
              if (occasion.isPast && day.weekday == DateTime.wednesday)
                Divider(
                  color: selected ? dayTheme.borderColor : borderColor,
                  height: borderWidth,
                  endIndent: 0,
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
                  child: child),
            ],
          ),
        ),
      );
}

class _FullDayActivities extends StatelessWidget {
  final DateTime day;
  final bool selected;

  const _FullDayActivities({
    required this.day,
    required this.selected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullDayActivities = context.select((WeekCalendarCubit cubit) =>
        cubit.state.fullDayActivities[day.weekday - 1] ?? []);
    if (fullDayActivities.length > 1) {
      return ClickableFullDayStack(
        fulldayActivitiesBuilder: (context) => fullDayActivities,
        numberOfActivities: fullDayActivities.length,
        day: day,
      );
    }
    if (fullDayActivities.length == 1) {
      return _WeekActivityContent(
        activityOccasion: fullDayActivities.first,
        selected: selected,
        fullDay: true,
      );
    }
    return const SizedBox.shrink();
  }
}

class _WeekDayColumn extends StatelessWidget {
  final DateTime day;
  final WeekDisplayDays weekDisplayDays;

  const _WeekDayColumn({
    required this.day,
    required this.weekDisplayDays,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memosettings) => BlocBuilder<ClockBloc, DateTime>(
        buildWhen: (previous, current) =>
            previous.isAtSameDay(day) != current.isAtSameDay(day),
        builder: (context, now) => BlocBuilder<DayPickerBloc, DayPickerState>(
          builder: (context, dayPickerState) {
            final wLayout = layout.weekCalendar;
            final past = day.isBefore(now.onlyDays());
            final selected = day.isAtSameDay(dayPickerState.day);
            final today = now.isAtSameDay(day);
            final borderWidth = selected || today
                ? wLayout.selectedDay.dayColumnBorderWidth
                : wLayout.notSelectedDay.dayColumnBorderWidth;
            final dayTheme = weekdayTheme(
              dayColor: memosettings.settings.calendar.dayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: day.weekday,
            );
            final columnColor = past
                ? AbiliaColors.white110
                : memosettings.weekColor == WeekColor.columns
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
                  DefaultTabController.of(context)?.animateTo(0);
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
                    child: _WeekDayColumnItems(
                      day: day,
                      selected: selected,
                      showCategories:
                          memosettings.settings.calendar.categories.show,
                      showCategoryColor:
                          memosettings.settings.calendar.categories.showColors,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeekDayColumnItems extends StatelessWidget {
  final DateTime day;
  final bool selected, showCategories, showCategoryColor;

  const _WeekDayColumnItems({
    required this.day,
    required this.selected,
    required this.showCategories,
    required this.showCategoryColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final occasions = context.select((WeekCalendarCubit cubit) =>
            cubit.state.currentWeekEvents)[day.weekday - 1] ??
        [];

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
            ),
          );
  }

  Widget _timerWidget(TimerOccasion occasion) {
    return selected && !layout.go
        ? TimerCard(
            timerOccasion: occasion,
            day: day,
            overflow: TextOverflow.clip,
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
    this.fullDay = false,
    Key? key,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;
  final bool selected, fullDay;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final inactive = activityOccasion.isPast || activityOccasion.isSignedOff;
    return Tts.fromSemantics(
      activityOccasion.activity.semanticsProperties(context),
      child: _WeekEventContent(
        occasion: activityOccasion,
        selected: selected && !fullDay,
        onClick: () {
          final authProviders = copiedAuthProviders(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: ActivityPage(activityDay: activityOccasion),
              ),
              settings: RouteSettings(
                name: 'ActivityPage $activityOccasion',
              ),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (activityOccasion.activity.hasImage)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: inactive ? 0.5 : 1.0,
                  child: FadeInAbiliaImage(
                    fit: selected || fullDay ? BoxFit.scaleDown : BoxFit.cover,
                    imageFileId: activityOccasion.activity.fileId,
                    imageFilePath: activityOccasion.activity.icon,
                    height: double.infinity,
                    width: double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                )
              else
                Center(
                  child: Text(
                    activityOccasion.activity.title,
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.caption ?? caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (activityOccasion.isPast)
                CrossOver(
                  style: CrossOverStyle.darkSecondary,
                  padding: wLayout.crossOverActivityPadding,
                ),
              if (activityOccasion.isSignedOff)
                FractionallySizedBox(
                  widthFactor: scaleFactor,
                  heightFactor: scaleFactor,
                  child: const CheckMark(),
                ),
            ],
          ),
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
    final textStyle = Theme.of(context).textTheme.caption ?? caption;

    return Tts.fromSemantics(
      timerOccasion.timer.semanticsProperties(context),
      child: _WeekEventContent(
        occasion: timerOccasion,
        selected: selected,
        onClick: () {
          final authProviders = copiedAuthProviders(context);
          final day = context.read<DayPickerBloc>().state.day;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: authProviders,
                child: TimerPage(
                  timerOccasion: timerOccasion,
                  day: day,
                ),
              ),
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
                          padding: wLayout.crossOverActivityPadding,
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
                  overflow: TextOverflow.clip,
                  maxLines: 1,
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
  final Widget child;

  const _WeekEventContent({
    required this.occasion,
    required this.onClick,
    required this.selected,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final borderRadius = selected
        ? wLayout.selectedDay.activityRadius
        : wLayout.notSelectedDay.activityRadius;
    final showColors = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.calendar.categories.showColors);
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
