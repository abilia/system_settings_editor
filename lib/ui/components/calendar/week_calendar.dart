import 'package:flutter_bloc/flutter_bloc.dart';
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
      floatingActionButton: FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Padding(
        padding: EdgeInsets.fromLTRB(2.s, 4.s, 2.s, 0),
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
        initialPage: context.read<WeekCalendarBloc>().state.index);
    return BlocListener<WeekCalendarBloc, WeekCalendarState>(
      listener: (context, state) {
        pageController.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, item) =>
            BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
          buildWhen: (oldState, newState) => newState.index == item,
          builder: (context, state) {
            if (state.index != item) return Container();
            return BlocBuilder<MemoplannerSettingBloc,
                MemoplannerSettingsState>(
              buildWhen: (previous, current) =>
                  previous.weekDisplayDays != current.weekDisplayDays,
              builder: (context, memosettings) => Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  WeekCalendarTop(),
                  Expanded(
                    child: WeekCalendarBody(
                        numberofDays:
                            memosettings.weekDisplayDays.numberOfDays()),
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

class WeekCalendarTop extends StatelessWidget {
  const WeekCalendarTop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.weekDisplayDays != current.weekDisplayDays,
      builder: (context, memosettings) =>
          BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
        buildWhen: (previous, current) =>
            previous.currentWeekStart != current.currentWeekStart,
        builder: (context, weekState) => Row(
          children: List<WeekCalendarDayHeading>.generate(
            memosettings.weekDisplayDays.numberOfDays(),
            (i) => WeekCalendarDayHeading(
              day: weekState.currentWeekStart.addDays(i),
            ),
          ),
        ),
      ),
    );
  }
}

class WeekCalendarDayHeading extends StatelessWidget {
  final DateTime day;

  const WeekCalendarDayHeading({
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
            final today = now.isAtSameDay(day);
            final dayTheme = weekdayTheme(
              dayColor: memosettings.calendarDayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: day.weekday,
            );
            return WeekCalenderHeadingContent(
              selected: selected,
              day: day,
              dayTheme: dayTheme,
              today: today,
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
    required this.today,
  }) : super(key: key);

  final DateTime day;
  final DayTheme dayTheme;
  final bool selected;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final weekDayFormat =
        DateFormat('EEEE', Localizations.localeOf(context).toLanguageTag());
    final borderColor = today
        ? AbiliaColors.red
        : selected
            ? AbiliaColors.black
            : dayTheme.borderColor;
    final thickBorder = selected || today;
    final borderSize = thickBorder ? 2.s : 1.s;
    final _bodyText1 = (dayTheme.theme.textTheme.bodyText1 ?? bodyText1);

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
              color: borderColor,
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
                  top: thickBorder ? 3.s : 4.s,
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
                        style: _bodyText1.copyWith(height: 18 / 16),
                        child: Tts.data(
                          data: '${day.day}, ${weekDayFormat.format(day)}',
                          child: BlocBuilder<ClockBloc, DateTime>(
                            buildWhen: (previous, current) =>
                                !previous.isAtSameDay(current),
                            builder: (context, now) => WithCrossOver(
                              color: _bodyText1.color,
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
                                      Translator.of(context)
                                          .translate
                                          .shortWeekday(day.weekday),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FullDayActivies(weekdayIndex: day.weekday - 1)
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

class FullDayActivies extends StatelessWidget {
  final int weekdayIndex;

  const FullDayActivies({Key? key, required this.weekdayIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
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
              height: 36.s,
              width: double.infinity);
        } else if (fullDayActivities.length == 1) {
          return WeekActivityContent(activityOccasion: fullDayActivities.first);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class WeekCalendarBody extends StatelessWidget {
  final int numberofDays;

  const WeekCalendarBody({Key? key, required this.numberofDays})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
        buildWhen: (previous, current) =>
            previous.currentWeekStart != current.currentWeekStart,
        builder: (context, weekState) => Row(
          mainAxisSize: MainAxisSize.max,
          children: List<WeekDayColumn>.generate(
            numberofDays,
            (i) => WeekDayColumn(
              day: weekState.currentWeekStart.addDays(i),
            ),
          ),
        ),
      ),
    );
  }
}

class WeekDayColumn extends StatelessWidget {
  final DateTime day;

  const WeekDayColumn({Key? key, required this.day}) : super(key: key);

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
            final selected = day.isAtSameDay(dayPickerState.day);
            final today = now.isAtSameDay(day);
            final thickBorder = selected || today;
            final borderSize = thickBorder ? 2.s : 1.s;
            final dayTheme = weekdayTheme(
              dayColor: memosettings.calendarDayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: day.weekday,
            );
            final borderColor = today
                ? AbiliaColors.red
                : selected
                    ? AbiliaColors.black
                    : dayTheme.borderColor;
            return Flexible(
              flex: selected ? 77 : 45,
              child: GestureDetector(
                onTap: () {
                  BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day));
                  DefaultTabController.of(context)?.animateTo(0);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 2.s, left: 2.s, bottom: 4.s),
                  child: Container(
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: radius,
                        bottomRight: radius,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsetsDirectional.only(
                          start: borderSize,
                          end: borderSize,
                          bottom: borderSize),
                      decoration: BoxDecoration(
                        color: memosettings.weekColor == WeekColor.columns
                            ? dayTheme.secondaryColor
                            : AbiliaColors.white110,
                        borderRadius: BorderRadius.only(
                          bottomLeft: innerRadiusFromBorderSize(borderSize),
                          bottomRight: innerRadiusFromBorderSize(borderSize),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 6.s, horizontal: 2.s),
                        child: BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
                          buildWhen: (previous, current) =>
                              previous.currentWeekActivities[day.weekday - 1] !=
                              current.currentWeekActivities[day.weekday - 1],
                          builder: (context, state) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...state.currentWeekActivities[day.weekday - 1]
                                      ?.where((ao) => !ao.activity.fullDay)
                                      .map(
                                        (ao) => Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.s),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: WeekActivityContent(
                                              activityOccasion: ao,
                                            ),
                                          ),
                                        ),
                                      ) ??
                                  [],
                            ],
                          ),
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

class WeekActivityContent extends StatelessWidget {
  const WeekActivityContent({
    Key? key,
    required this.activityOccasion,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;

  @override
  Widget build(BuildContext context) {
    final inactive = activityOccasion.isPast || activityOccasion.isSignedOff;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.showCategoryColor != current.showCategoryColor &&
          previous.showCategories != current.showCategories,
      builder: (context, settings) {
        return Container(
          clipBehavior: Clip.hardEdge,
          height: activityOccasion.activity.fullDay ? 36.s : null,
          foregroundDecoration: BoxDecoration(
            border: getCategoryBorder(
              inactive: inactive,
              current: activityOccasion.isCurrent,
              showCategoryColor: settings.showCategoryColor &&
                  !activityOccasion.activity.fullDay,
              category: activityOccasion.activity.category,
            ),
            borderRadius: borderRadius,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: AbiliaColors.white,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (activityOccasion.activity.hasImage)
                AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: inactive ? 0.5 : 1.0,
                  child: FadeInAbiliaImage(
                    imageFileId: activityOccasion.activity.fileId,
                    imageFilePath: activityOccasion.activity.icon,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.all(3.0.s),
                  child: Center(
                    child: Tts(
                      child: Text(
                        activityOccasion.activity.title,
                        overflow: TextOverflow.clip,
                        style: (Theme.of(context).textTheme.caption ?? caption)
                            .copyWith(height: 20 / 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (activityOccasion.isSignedOff)
                FractionallySizedBox(
                  widthFactor: scaleFactor,
                  heightFactor: scaleFactor,
                  child: CheckMark(),
                )
              else if (activityOccasion.isPast)
                FractionallySizedBox(
                  widthFactor: scaleFactor,
                  heightFactor: scaleFactor,
                  child: CrossOver(),
                ),
            ],
          ),
        );
      },
    );
  }
}
