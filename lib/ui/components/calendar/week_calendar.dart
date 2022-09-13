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
          buildWhen: (oldState, newState) => newState.index == item,
          builder: (context, state) {
            if (state.index != item) return Container();
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: const [
                _WeekCalendarTop(),
                Expanded(
                  child: _WeekCalendarBody(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeekCalendarTop extends StatelessWidget {
  const _WeekCalendarTop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.weekDisplayDays != current.weekDisplayDays,
        builder: (context, memosettings) =>
            BlocBuilder<WeekCalendarCubit, WeekCalendarState>(
          buildWhen: (previous, current) =>
              previous.currentWeekStart != current.currentWeekStart,
          builder: (context, weekState) => Row(
            children: List<_WeekCalendarDayHeading>.generate(
              memosettings.weekDisplayDays.numberOfDays(),
              (i) => _WeekCalendarDayHeading(
                day: weekState.currentWeekStart.addDays(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekCalendarDayHeading extends StatelessWidget {
  final DateTime day;

  const _WeekCalendarDayHeading({
    required this.day,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayColor = context.select<MemoplannerSettingBloc, DayColor>(
        (bloc) => bloc.state.settings.calendar.dayColor);
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    final selected = context
        .select<DayPickerBloc, bool>((bloc) => bloc.state.day.isAtSameDay(day));
    final weekDisplayDays =
        context.select<MemoplannerSettingBloc, WeekDisplayDays>(
            (bloc) => bloc.state.weekDisplayDays);
    final dayOccasion =
        context.select((ClockBloc clock) => day.dayOccasion(clock.state));
    return WeekCalenderHeadingContent(
      selected: selected,
      day: day,
      dayTheme: dayTheme,
      weekDisplayDays: weekDisplayDays,
      occasion: dayOccasion,
    );
  }
}

class WeekCalenderHeadingContent extends StatelessWidget {
  const WeekCalenderHeadingContent({
    required this.day,
    required this.dayTheme,
    required this.selected,
    required this.weekDisplayDays,
    required this.occasion,
    Key? key,
  }) : super(key: key);

  final DateTime day;
  final DayTheme dayTheme;
  final bool selected;
  final WeekDisplayDays weekDisplayDays;
  final Occasion occasion;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
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
          final currentDay = context.read<DayPickerBloc>().state.day;
          if (currentDay.isAtSameDay(day)) {
            DefaultTabController.of(context)?.animateTo(0);
          } else {
            BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wLayout.dayDistance),
          child: Container(
            height: wLayout.headerHeight,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.only(
                topLeft: wLayout.columnRadius,
                topRight: wLayout.columnRadius,
              ),
            ),
            child: Container(
              margin: EdgeInsetsDirectional.only(
                bottom: occasion.isPast ? borderWidth : 0.0,
              ),
              decoration: BoxDecoration(
                color: dayTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: innerRadius,
                  topRight: innerRadius,
                ),
              ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
        fulldayActivitiesBuilder: (context) => context.select(
            (WeekCalendarCubit cubit) =>
                cubit.state.fullDayActivities[day.weekday - 1] ?? []),
        numberOfActivities: fullDayActivities.length,
        day: day,
      );
    } else if (fullDayActivities.length == 1) {
      return _WeekActivityContent(
        activityOccasion: fullDayActivities.first,
        selected: selected,
      );
    }
    return const SizedBox.shrink();
  }
}

class _WeekCalendarBody extends StatelessWidget {
  const _WeekCalendarBody({Key? key}) : super(key: key);

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
              child:
                  BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
                buildWhen: (previous, current) =>
                    previous.weekDisplayDays != current.weekDisplayDays,
                builder: (context, memosettings) =>
                    BlocBuilder<WeekCalendarCubit, WeekCalendarState>(
                  buildWhen: (previous, current) =>
                      previous.currentWeekStart != current.currentWeekStart,
                  builder: (context, weekState) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List<_WeekDayColumn>.generate(
                      memosettings.weekDisplayDays.numberOfDays(),
                      (i) => _WeekDayColumn(
                        day: weekState.currentWeekStart.addDays(i),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDayColumn extends StatelessWidget {
  final DateTime day;

  const _WeekDayColumn({
    required this.day,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.weekColor != current.weekColor ||
          previous.settings.calendar.dayColor !=
              current.settings.calendar.dayColor,
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
            final borderColor = today
                ? AbiliaColors.red
                : selected
                    ? AbiliaColors.black
                    : past
                        ? AbiliaColors.white110
                        : columnColor == AbiliaColors.white
                            ? AbiliaColors.white120
                            : dayTheme.borderColor ?? dayTheme.secondaryColor;
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
              flex: _dayColumnFlex(memosettings.weekDisplayDays, selected),
              child: GestureDetector(
                onTap: () {
                  DefaultTabController.of(context)?.animateTo(0);
                  BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wLayout.dayDistance,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: wLayout.columnRadius,
                        bottomRight: wLayout.columnRadius,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsetsDirectional.only(
                        start: borderWidth,
                        end: borderWidth,
                        bottom: borderWidth,
                      ),
                      decoration: BoxDecoration(
                        color: columnColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: innerRadius,
                          bottomRight: innerRadius,
                        ),
                      ),
                      child: Padding(
                        padding: innerDayPadding,
                        child: _WeekDayColumnItems(
                          day: day,
                          selected: selected,
                          showCategories:
                              memosettings.settings.calendar.categories.show,
                          showCategoryColor: memosettings
                              .settings.calendar.categories.showColors,
                        ),
                      ),
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
            child: selected && !layout.go
                ? occasions[i] is ActivityOccasion
                    ? ActivityCard(
                        activityOccasion: occasions[i] as ActivityOccasion,
                        showCategoryColor: showCategoryColor,
                        showInfoIcons: false,
                      )
                    : TimerCard(
                        timerOccasion: occasions[i] as TimerOccasion,
                        day: day,
                      )
                : occasions[i] is ActivityOccasion
                    ? _WeekActivityContent(
                        activityOccasion: occasions[i] as ActivityOccasion,
                        selected: selected,
                      )
                    : _WeekTimerContent(
                        timerOccasion: occasions[i] as TimerOccasion,
                        selected: selected,
                      ),
          ),
      ],
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
    Key? key,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final inactive = activityOccasion.isPast || activityOccasion.isSignedOff;
    return AspectRatio(
      aspectRatio: 1,
      child: Tts.fromSemantics(
        activityOccasion.activity.semanticsProperties(context),
        child: _WeekEventContent(
          occasion: activityOccasion,
          selected: selected,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (activityOccasion.activity.hasImage)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: inactive ? 0.5 : 1.0,
                  child: FadeInAbiliaImage(
                    fit: selected ? BoxFit.scaleDown : BoxFit.cover,
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
                AspectRatio(
                  aspectRatio: 1,
                  child: CrossOver(
                    style: CrossOverStyle.darkSecondary,
                    padding: wLayout.crossOverActivityPadding,
                  ),
                ),
              if (activityOccasion.isSignedOff)
                AspectRatio(
                  aspectRatio: 1,
                  child: FractionallySizedBox(
                    widthFactor: scaleFactor,
                    heightFactor: scaleFactor,
                    child: const CheckMark(),
                  ),
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: timerOccasion.isPast ? 0.5 : 1.0,
                        child: FadeInAbiliaImage(
                          fit: selected ? BoxFit.scaleDown : BoxFit.cover,
                          imageFileId: timerOccasion.timer.fileId,
                          height: double.infinity,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(
                            wLayout.timerCard.borderRadius,
                          ),
                        ),
                      ),
                    ),
                    if (timerOccasion.isPast)
                      AspectRatio(
                        aspectRatio: 1,
                        child: CrossOver(
                          style: CrossOverStyle.darkSecondary,
                          padding: wLayout.crossOverActivityPadding,
                        ),
                      ),
                  ],
                ),
              )
            else if (timerOccasion.timer.hasTitle)
              Padding(
                padding: wLayout.timerCard.textPadding,
                child: Text(
                  timerOccasion.timer.title,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
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
