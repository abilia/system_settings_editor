// @dart=2.9

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
    return Scaffold(
      backgroundColor: AbiliaColors.white,
      appBar: const WeekAppBar(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(2.s, 4.s, 2.s, 0),
        child: const WeekCalendar(),
      ),
    );
  }
}

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        WeekCalendarTop(),
        Expanded(
          child: WeekCalendarBody(),
        ),
      ],
    );
  }
}

class WeekCalendarTop extends StatelessWidget {
  const WeekCalendarTop({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
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
      ),
    );
  }
}

class WeekCalendarDayHeading extends StatelessWidget {
  final DateTime day;

  const WeekCalendarDayHeading({
    Key key,
    @required this.day,
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
          buildWhen: (previous, current) =>
              previous.day.isAtSameDay(day) != current.day.isAtSameDay(day),
          builder: (context, dayPickerState) {
            final selected = dayPickerState.day.isAtSameDay(day);
            final today = now.isAtSameDay(day);
            final thickBorder = selected || today;
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

            final borderSize = thickBorder ? 2.s : 1.s;
            final weekDayFormat = DateFormat(
                'EEEE', Localizations.localeOf(context).toLanguageTag());
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
                                style: dayTheme.theme.textTheme.bodyText1
                                    .copyWith(height: 18 / 16),
                                child: Tts(
                                    data:
                                        '${day.day}, ${weekDayFormat.format(day)}',
                                    child: BlocBuilder<ClockBloc, DateTime>(
                                      buildWhen: (previous, current) =>
                                          !previous.isAtSameDay(current),
                                      builder: (context, now) => WithCrossOver(
                                        color: dayTheme
                                            .theme.textTheme.bodyText1.color,
                                        crossOverPadding: EdgeInsets.fromLTRB(
                                            4.s, 4.s, 4.s, 12.s),
                                        applyCross:
                                            day.isBefore(now.onlyDays()),
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
                                    )),
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
          },
        ),
      ),
    );
  }
}

class FullDayActivies extends StatelessWidget {
  final int weekdayIndex;

  const FullDayActivies({Key key, this.weekdayIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
      buildWhen: (previous, current) =>
          previous.currentWeekActivities[weekdayIndex] !=
          current.currentWeekActivities[weekdayIndex],
      builder: (context, state) {
        final fullDayActivities = state.currentWeekActivities[weekdayIndex]
            .where((a) => a.activity.fullDay)
            .toList();
        if (fullDayActivities.length > 1) {
          return FullDayStack(numberOfActivities: fullDayActivities.length);
        } else if (fullDayActivities.length == 1) {
          return FullDayActivity(activityOccasion: fullDayActivities.first);
        }
        return const SizedBox.shrink();
      },
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
  const WeekCalendarBody({Key key}) : super(key: key);

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
                    BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
                  buildWhen: (previous, current) =>
                      previous.currentWeekStart != current.currentWeekStart,
                  builder: (context, weekState) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List<WeekDayColumn>.generate(
                      memosettings.weekDisplayDays.numberOfDays(),
                      (i) => WeekDayColumn(
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

class WeekDayColumn extends StatelessWidget {
  final DateTime day;
  const WeekDayColumn({Key key, @required this.day}) : super(key: key);

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
                  DefaultTabController.of(context).animateTo(0);
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
                            children: state
                                .currentWeekActivities[day.weekday - 1]
                                .where((ao) => !ao.activity.fullDay)
                                .map(
                                  (ao) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.s),
                                    child: WeekActivity(activityOccasion: ao),
                                  ),
                                )
                                .toList(),
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
      foregroundDecoration: BoxDecoration(
        border: activityOccasion.isCurrent ? currentActivityBorder : border,
        borderRadius: borderRadius,
      ),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AbiliaColors.white,
      ),
      child: activityOccasion.activity.hasImage
          ? ActivityImage.fromActivityOccasion(
              activityOccasion: activityOccasion,
              size: double.infinity,
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
