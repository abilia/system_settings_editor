import 'dart:math';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimepillarCalendar extends StatelessWidget {
  const TimepillarCalendar({
    required this.timepillarState,
    required this.timepillarMeasures,
    Key? key,
  }) : super(key: key);

  final TimepillarState timepillarState;
  final TimepillarMeasures timepillarMeasures;

  @override
  Widget build(BuildContext context) {
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);

    if (timepillarState.calendarType == DayCalendarType.oneTimepillar) {
      final isNight = context.watch<NightMode>().state;
      final notDayAndNightTimepillar = context.select(
        (MemoplannerSettingsBloc settings) =>
            settings.state.dayCalendar.viewOptions.intervalType !=
            TimepillarIntervalType.dayAndNight,
      );
      final nightMode = isNight && notDayAndNightTimepillar;

      return OneTimepillarCalendar(
        timepillarState: timepillarState,
        timepillarMeasures: timepillarMeasures,
        dayParts: calendarSettings.dayParts,
        displayTimeline: calendarSettings.timepillar.timeline,
        showCategories: calendarSettings.categories.show,
        displayHourLines: calendarSettings.timepillar.hourLines,
        nightMode: nightMode,
      );
    }
    return TwoTimepillarCalendar(
      timepillarState: timepillarState,
      showCategories: calendarSettings.categories.show,
      displayHourLines: calendarSettings.timepillar.hourLines,
      displayTimeline: calendarSettings.timepillar.timeline,
      dayParts: calendarSettings.dayParts,
    );
  }
}

class OneTimepillarCalendar extends StatelessWidget with CalendarWidgetMixin {
  final TimepillarState timepillarState;
  final TimepillarMeasures timepillarMeasures;
  final bool showCategories,
      displayHourLines,
      displayTimeline,
      showCategoryLabels,
      scrollToTimeOffset,
      pullToRefresh,
      nightMode;
  final DayParts dayParts;
  final double topMargin, bottomMargin;
  final Key center = const Key('center');

  OneTimepillarCalendar({
    required this.timepillarState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
    required this.timepillarMeasures,
    this.scrollToTimeOffset = true,
    this.pullToRefresh = true,
    this.nightMode = false,
    double? topMargin,
    double? bottomMargin,
    bool? showCategoryLabels,
    Key? key,
  })  : showCategoryLabels = showCategoryLabels ?? showCategories,
        topMargin = topMargin ?? layout.templates.l1.top,
        bottomMargin = bottomMargin ?? layout.templates.l1.bottom,
        super(key: key);

  bool get showTimeLine => timepillarState.isToday && displayTimeline;

  TimepillarMeasures get measures => timepillarMeasures;

  TimepillarInterval get interval => timepillarMeasures.interval;

  @override
  Widget build(BuildContext context) {
    final horizontalScrollController = SnapToCenterScrollController();
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        double getNowOffset(DateTime now) =>
            currentDotMidPosition(now, measures, topMargin: topMargin) -
            (boxConstraints.maxHeight / 4);
        final events = timepillarState.eventsForInterval(interval);
        final np = interval.intervalPart == IntervalPart.dayAndNight
            ? nightParts(dayParts, measures, topMargin)
            : <NightPart>[];

        final timepillarArguments = TimepillarBoardDataArguments(
          textStyle: layout.timepillar.card.textStyle(
            zoom: measures.zoom,
            nightMode: nightMode,
          ),
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
          dayParts: dayParts,
          measures: measures,
          topMargin: topMargin,
          bottomMargin: bottomMargin,
          showCategoryColor: context.select((MemoplannerSettingsBloc bloc) =>
              bloc.state.calendar.categories.showColors),
          nightMode: nightMode,
        );

        return BlocBuilder<ClockBloc, DateTime>(
          builder: (context, now) {
            final timelineOffset =
                currentDotMidPosition(now, measures, topMargin: topMargin) -
                    (layout.timepillar.timeLineHeight / 2);
            final leftBoardData = TimepillarBoard.positionTimepillarCards(
              eventOccasions: showCategories
                  ? events
                      .where((ao) => ao.category != Category.right)
                      .map((e) => e.toOccasion(now))
                      .toList()
                  : <ActivityOccasion>[],
              args: timepillarArguments,
              timepillarSide: TimepillarSide.left,
              timelineOffset: timelineOffset,
            );
            final rightBoardData = TimepillarBoard.positionTimepillarCards(
              eventOccasions: (showCategories
                      ? events.where((ao) => ao.category == Category.right)
                      : events)
                  .map((e) => e.toOccasion(now))
                  .toList(),
              args: timepillarArguments,
              timepillarSide: TimepillarSide.right,
              timelineOffset: timelineOffset,
            );

            // Anchor is the starting point of the central sliver (timepillar).
            // horizontalAnchor is where the left side of the timepillar needs to be
            // in parts of the screen to make it centralized.
            final maxWidth = boxConstraints.maxWidth;
            final timePillarPercentOfTotalScreen =
                (measures.timePillarTotalWidth) / maxWidth;
            final horizontalAnchor =
                showCategories ? 0.5 - timePillarPercentOfTotalScreen / 2 : 0.0;
            final categoryMinWidth =
                (1 - timePillarPercentOfTotalScreen) * maxWidth / 2;

            final tsHeight =
                measures.timePillarHeight + topMargin + bottomMargin;
            final calendarHeight =
                max(tsHeight, max(leftBoardData.height, rightBoardData.height));
            final height = max(calendarHeight, boxConstraints.maxHeight);
            final timepillarSettings = context.select(
                (MemoplannerSettingsBloc bloc) =>
                    bloc.state.calendar.timepillar);
            return CalendarScrollListener(
              timepillarMeasures: measures,
              enabled: timepillarState.isToday && scrollToTimeOffset,
              disabledInitOffset:
                  timepillarState.calendarType == DayCalendarType.oneTimepillar
                      ? measures.hourHeight * dayParts.morning.inHours
                      : 0,
              getNowOffset: getNowOffset,
              inViewMargin: timeToPixels(
                0,
                minutesPerDotDuration.inMinutes,
                measures.dotDistance,
              ),
              builder: (_, verticalController) {
                return RefreshIndicator(
                  onRefresh: () => refresh(context),
                  notificationPredicate: (scrollNotification) =>
                      pullToRefresh &&
                      defaultScrollNotificationPredicate(scrollNotification),
                  child: Container(
                    key: TestKey.calendarBackgroundColor,
                    color: interval.intervalPart == IntervalPart.night
                        ? nightBackgroundColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    child: ScrollArrows.all(
                      upCollapseMargin: topMargin,
                      downCollapseMargin: bottomMargin,
                      horizontalController: horizontalScrollController,
                      verticalController: verticalController,
                      child: SingleChildScrollView(
                        controller: verticalController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: LimitedBox(
                          maxHeight: height,
                          child: Stack(
                            children: <Widget>[
                              ...np.map((p) {
                                return Positioned(
                                  top: p.start,
                                  child: SizedBox(
                                    width: boxConstraints.maxWidth,
                                    height: p.length,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: nightBackgroundColor,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              if (displayHourLines)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: topMargin,
                                  ),
                                  child: HourLines(
                                    numberOfLines: interval.lengthInHours + 1,
                                    hourHeight: measures.hourHeight,
                                  ),
                                ),
                              if (showTimeLine)
                                Builder(
                                  builder: (context) {
                                    if (now.inRangeWithInclusiveStart(
                                        startDate: measures.interval.start,
                                        endDate: measures.interval.end)) {
                                      return Timeline(
                                        top: timelineOffset,
                                        width: boxConstraints.maxWidth,
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              CustomScrollView(
                                anchor: horizontalAnchor,
                                center: center,
                                scrollDirection: Axis.horizontal,
                                controller: horizontalScrollController,
                                slivers: <Widget>[
                                  if (showCategories)
                                    SliverToBoxAdapter(
                                      child: TimepillarBoard(
                                        leftBoardData,
                                        categoryMinWidth: categoryMinWidth,
                                        timepillarWidth:
                                            measures.cardTotalWidth,
                                        textStyle:
                                            timepillarArguments.textStyle,
                                      ),
                                    ),
                                  SliverTimePillar(
                                    key: center,
                                    child: TimePillar(
                                      interval: interval,
                                      dayOccasion: timepillarState.occasion,
                                      use12h: timepillarSettings.use12h,
                                      nightParts: np,
                                      dayParts: dayParts,
                                      columnOfDots:
                                          timepillarSettings.columnOfDots,
                                      topMargin: topMargin,
                                      measures: measures,
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: TimepillarBoard(
                                      rightBoardData,
                                      categoryMinWidth: categoryMinWidth,
                                      timepillarWidth: measures.cardTotalWidth,
                                      textStyle: timepillarArguments.textStyle,
                                    ),
                                  ),
                                ],
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
          },
        );
      },
    );
  }

  List<NightPart> nightParts(
    DayParts dayParts,
    TimepillarMeasures measures,
    double topMargin,
  ) {
    final interval = measures.interval;
    final intervalDay = interval.start.onlyDays();
    return <NightPart>[
      if (interval.start.isBefore(intervalDay.add(dayParts.morning)))
        NightPart(
          0,
          hoursToPixels(intervalDay.add(dayParts.morning).hour,
                  measures.dotDistance) +
              topMargin,
        ),
      if (interval.end.isAfter(intervalDay.add(dayParts.night)))
        NightPart(
            hoursToPixels(intervalDay.add(dayParts.night).hour,
                    measures.dotDistance) +
                topMargin,
            hoursToPixels(interval.end.hour == 0 ? 24 : interval.end.hour,
                measures.dotDistance))
    ];
  }
}

class SnapToCenterScrollController extends ScrollController {
  double prevScroll = 0;

  SnapToCenterScrollController() {
    addListener(() {
      final currentScroll = position.pixels;
      if (prevScroll == 0) {
        prevScroll = currentScroll;
        return;
      }
      if (currentScroll.isNegative != prevScroll.isNegative) {
        prevScroll = 0;
        jumpTo(0);
        return;
      }
      prevScroll = currentScroll;
    });
  }
}

class NightPart {
  final double start, length;

  NightPart(this.start, this.length);
}

double currentDotMidPosition(
  DateTime now,
  TimepillarMeasures measures, {
  required double topMargin,
}) {
  return timeToMidDotPixelDistance(
        now: now,
        dotDistance: measures.dotDistance,
        dotSize: measures.dotSize,
      ) +
      topMargin -
      measures.topOffset(now) +
      measures.topPadding;
}
