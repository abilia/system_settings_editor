import 'dart:math';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

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
        initialPage: context.read<WeekCalendarCubit>().state.index);
    return BlocListener<WeekCalendarCubit, WeekCalendarState>(
      listener: (context, state) {
        pageController.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
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
    Key? key,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.calendarDayColor != current.calendarDayColor,
      builder: (context, memosettings) => BlocBuilder<ClockBloc, DateTime>(
        buildWhen: (previous, current) =>
            previous.isAtSameDay(day) != current.isAtSameDay(day),
        builder: (context, now) => BlocBuilder<DayPickerBloc, DayPickerState>(
          builder: (context, dayPickerState) {
            final selected = dayPickerState.day.isAtSameDay(day);
            final dayTheme = weekdayTheme(
              dayColor: memosettings.calendarDayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: day.weekday,
            );
            return WeekCalenderHeadingContent(
              selected: selected,
              day: day,
              dayTheme: dayTheme,
              weekDisplayDays: memosettings.weekDisplayDays,
              occasion: day.dayOccasion(now),
            );
          },
        ),
      ),
    );
  }
}

class WeekCalenderHeadingContent extends StatelessWidget {
  const WeekCalenderHeadingContent({
    Key? key,
    required this.day,
    required this.dayTheme,
    required this.selected,
    required this.weekDisplayDays,
    required this.occasion,
  }) : super(key: key);

  final DateTime day;
  final DayTheme dayTheme;
  final bool selected;
  final WeekDisplayDays weekDisplayDays;
  final Occasion occasion;

  @override
  Widget build(BuildContext context) {
    final wLayout = layout.weekCalendar;
    final weekDayFormat =
        DateFormat('EEEE', Localizations.localeOf(context).toLanguageTag());
    final borderColor = occasion.isCurrent
        ? AbiliaColors.red
        : selected
            ? AbiliaColors.black
            : occasion.isPast
                ? AbiliaColors.black80
                : dayTheme.borderColor ?? dayTheme.color;
    final borderWidth = selected || occasion.isCurrent
        ? wLayout.selectedDay.dayColumnBorderWidth
        : wLayout.notSelectedDay.dayColumnBorderWidth;
    final _bodyText1 = (dayTheme.theme.textTheme.bodyText1 ?? bodyText1)
        .copyWith(height: 18 / 16);
    final innerRadius = Radius.circular(wLayout.columnRadius.x - borderWidth);
    final _fullDayPadding = selected
        ? wLayout.selectedDay.innerDayPadding.horizontal / 2
        : wLayout.notSelectedDay.innerDayPadding.horizontal / 2;
    final fullDayActivitiesPadding = EdgeInsets.symmetric(
      horizontal: max(
        _fullDayPadding - borderWidth,
        0,
      ),
      vertical: _fullDayPadding,
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
                start: borderWidth,
                end: borderWidth,
                top: borderWidth,
              ),
              decoration: BoxDecoration(
                color: occasion.isPast ? AbiliaColors.black80 : dayTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: innerRadius,
                  topRight: innerRadius,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Tts.data(
                      data: '${day.day}, ${weekDayFormat.format(day)}',
                      child: BlocBuilder<ClockBloc, DateTime>(
                        buildWhen: (previous, current) =>
                            !previous.isAtSameDay(current),
                        builder: (context, now) => CrossOver(
                          style: CrossOverStyle.lightDefault,
                          applyCross: occasion.isPast,
                          padding: wLayout.crossOverDayHeadingPadding,
                          child: Center(
                            child: Text(
                              '${day.day}\n${Translator.of(context).translate.shortWeekday(day.weekday)}',
                              textAlign: TextAlign.center,
                              style: occasion.isPast
                                  ? _bodyText1.copyWith(
                                      color: AbiliaColors.white)
                                  : _bodyText1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: fullDayActivitiesPadding,
                        child: _FullDayActivities(
                          weekdayIndex: day.weekday - 1,
                          selectedDay: selected,
                        ),
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
  final int weekdayIndex;
  final bool selectedDay;

  const _FullDayActivities({
    Key? key,
    required this.weekdayIndex,
    required this.selectedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeekCalendarCubit, WeekCalendarState>(
      buildWhen: (previous, current) =>
          previous.currentWeekActivities[weekdayIndex] !=
          current.currentWeekActivities[weekdayIndex],
      builder: (context, state) {
        final fullDayActivities = state.currentWeekActivities[weekdayIndex]
                ?.where((a) => a.activity.fullDay)
                .toList() ??
            [];
        if (fullDayActivities.length > 1) {
          return FullDayStack(
            numberOfActivities: fullDayActivities.length,
          );
        } else if (fullDayActivities.length == 1) {
          return _WeekActivityContent(
            activityOccasion: fullDayActivities.first,
            selectedDay: selectedDay,
          );
        }
        return const SizedBox.shrink();
      },
    );
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

  const _WeekDayColumn({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.weekColor != current.weekColor ||
          previous.calendarDayColor != current.calendarDayColor,
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
              dayColor: memosettings.calendarDayColor,
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
            final _tempPadding = selected
                ? wLayout.selectedDay.innerDayPadding
                : wLayout.notSelectedDay.innerDayPadding;
            final innerDayPadding = _tempPadding.copyWith(
              left: max(_tempPadding.left - borderWidth, 0),
              right: max(_tempPadding.right - borderWidth, 0),
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
                          showCategories: memosettings.showCategories,
                          showCategoryColor: memosettings.showCategoryColor,
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
    Key? key,
    required this.day,
    required this.selected,
    required this.showCategories,
    required this.showCategoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeekCalendarCubit, WeekCalendarState>(
      buildWhen: (previous, current) =>
          previous.currentWeekActivities[day.weekday - 1] !=
          current.currentWeekActivities[day.weekday - 1],
      builder: (context, state) {
        final List<Widget> items = [];
        final activityOccasions = state.currentWeekActivities[day.weekday - 1]
                ?.where((ao) => !ao.activity.fullDay)
                .toList() ??
            [];
        for (int i = 0; i < activityOccasions.length; i++) {
          final newCategory = i > 0 &&
              activityOccasions[i - 1].category !=
                  activityOccasions[i].category;

          items.add(
            Padding(
              padding: _categoryPadding(
                showCategories,
                selected,
                activityOccasions[i].category,
                newCategory,
              ),
              child: selected && !layout.go
                  ? SizedBox(
                      child: ActivityCard(
                        activityOccasion: activityOccasions[i],
                        showCategoryColor: showCategoryColor,
                        showInfoIcons: false,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 1,
                      child: _WeekActivityContent(
                        activityOccasion: activityOccasions[i],
                        selectedDay: selected,
                      ),
                    ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        );
      },
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
    Key? key,
    required this.activityOccasion,
    required this.selectedDay,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;
  final bool selectedDay;

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final wLayout = layout.weekCalendar;
    final inactive = activityOccasion.isPast || activityOccasion.isSignedOff;
    final borderRadius = selectedDay && !activityOccasion.activity.fullDay
        ? wLayout.selectedDay.activityRadius
        : wLayout.notSelectedDay.activityRadius;

    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.showCategoryColor != current.showCategoryColor &&
          previous.showCategories != current.showCategories,
      builder: (context, settings) {
        final categoryBorder = getCategoryBorder(
          inactive: inactive,
          current: activityOccasion.isCurrent,
          showCategoryColor:
              settings.showCategoryColor && !activityOccasion.activity.fullDay,
          category: activityOccasion.activity.category,
          borderWidth: selectedDay
              ? wLayout.selectedDay.activityBorderWidth
              : wLayout.notSelectedDay.activityBorderWidth,
          currentBorderWidth: selectedDay
              ? wLayout.selectedDay.currentActivityBorderWidth
              : wLayout.notSelectedDay.currentActivityBorderWidth,
        );
        return Tts.fromSemantics(
          activityOccasion.activity.semanticsProperties(context),
          child: GestureDetector(
            onTap: () {
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
                  color: activityOccasion.isPast &&
                          !activityOccasion.activity.fullDay
                      ? AbiliaColors.white110
                      : AbiliaColors.white,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (activityOccasion.activity.hasImage)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: inactive ? 0.5 : 1.0,
                          child: FadeInAbiliaImage(
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
                            style:
                                Theme.of(context).textTheme.caption ?? caption,
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
            ),
          ),
        );
      },
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
