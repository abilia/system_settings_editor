import 'dart:math';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimepillarCalendar extends StatelessWidget {
  static const nightBackgroundColor = AbiliaColors.black;
  const TimepillarCalendar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.dayParts != current.dayParts ||
          previous.displayTimeline != current.displayTimeline ||
          previous.showCategories != current.showCategories ||
          previous.displayHourLines != current.displayHourLines,
      builder: (context, memoplannerSettingsState) =>
          BlocBuilder<TimepillarCubit, TimepillarState>(
        builder: (context, timepillarState) => timepillarState.calendarType ==
                DayCalendarType.oneTimepillar
            ? BlocBuilder<TimepillarMeasuresCubit, TimepillarMeasures>(
                builder: (context, measures) => OneTimepillarCalendar(
                  timepillarState: timepillarState,
                  timepillarMeasures: measures,
                  dayParts: memoplannerSettingsState.dayParts,
                  displayTimeline: memoplannerSettingsState.displayTimeline,
                  showCategories: memoplannerSettingsState.showCategories,
                  displayHourLines: memoplannerSettingsState.displayHourLines,
                ),
              )
            : TwoTimepillarCalendar(
                timepillarState: timepillarState,
                showCategories: memoplannerSettingsState.showCategories,
                displayHourLines: memoplannerSettingsState.displayHourLines,
                displayTimeline: memoplannerSettingsState.displayTimeline,
                dayParts: memoplannerSettingsState.dayParts,
              ),
      ),
    );
  }
}

class OneTimepillarCalendar extends StatefulWidget {
  final TimepillarState timepillarState;
  final TimepillarMeasures timepillarMeasures;
  final bool showCategories,
      displayHourLines,
      displayTimeline,
      showCategoryLabels,
      scrollToTimeOffset;
  final DayParts dayParts;
  final double topMargin, bottomMargin;

  OneTimepillarCalendar({
    required this.timepillarState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
    required this.timepillarMeasures,
    this.scrollToTimeOffset = true,
    double? topMargin,
    double? bottomMargin,
    bool? showCategoryLabels,
    Key? key,
  })  : showCategoryLabels = showCategoryLabels ?? showCategories,
        topMargin = topMargin ?? layout.timepillar.topMargin,
        bottomMargin = bottomMargin ?? layout.timepillar.bottomMargin,
        super(key: key);

  @override
  State createState() => _OneTimepillarCalendarState();
}

class _OneTimepillarCalendarState extends State<OneTimepillarCalendar>
    with CalendarStateMixin {
  late final ScrollController verticalScrollController;
  late final ScrollController horizontalScrollController;
  final Key center = const Key('center');

  bool get enableScrollNotification =>
      widget.timepillarState.isToday && widget.scrollToTimeOffset;
  bool get showTimeLine =>
      widget.timepillarState.isToday && widget.displayTimeline;
  TimepillarMeasures get measures => widget.timepillarMeasures;
  double get topMargin => widget.topMargin;
  double get bottomMargin => widget.topMargin;

  TimepillarInterval get interval => widget.timepillarMeasures.interval;

  @override
  void initState() {
    super.initState();
    verticalScrollController = widget.scrollToTimeOffset
        ? _timeOffsetVerticalScroll()
        : ScrollController();
    horizontalScrollController = SnapToCenterScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ScrollPositionCubit>().scrollViewRenderComplete(
            verticalScrollController,
            createdTime: context.read<ClockBloc>().state,
          ),
    );
  }

  ScrollController _timeOffsetVerticalScroll() {
    final now = context.read<ClockBloc>().state;
    final scrollOffset = widget.timepillarState.isToday
        ? timeToPixels(now.hour, now.minute, measures.dotDistance) -
            measures.hourHeight * 2 +
            topMargin -
            hoursToPixels(interval.start.hour, measures.dotDistance)
        : measures.hourHeight * widget.dayParts.morning.inHours;
    return ScrollController(initialScrollOffset: max(scrollOffset, 0));
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final showCategoryColor = context.select(
        (MemoplannerSettingBloc settingsBloc) =>
            settingsBloc.state.showCategoryColor);
    final textStyle = layout.timepillar.card.textStyle(measures.zoom);
    final textScaleFactor = mediaData.textScaleFactor;
    final events = widget.timepillarState.eventsForInterval(interval);
    final np = interval.intervalPart == IntervalPart.dayAndNight
        ? nightParts(widget.dayParts, measures, topMargin)
        : <NightPart>[];

    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) {
        final leftBoardData = TimepillarBoard.positionTimepillarCards(
          eventOccasions: widget.showCategories
              ? events
                  .where((ao) => ao.category != Category.right)
                  .map((e) => e.toOccasion(now))
                  .toList()
              : <ActivityOccasion>[],
          textStyle: textStyle,
          textScaleFactor: textScaleFactor,
          dayParts: widget.dayParts,
          timepillarSide: TimepillarSide.left,
          measures: measures,
          topMargin: topMargin,
          bottomMargin: bottomMargin,
          showCategoryColor: showCategoryColor,
        );
        final rightBoardData = TimepillarBoard.positionTimepillarCards(
          eventOccasions: (widget.showCategories
                  ? events.where((ao) => ao.category == Category.right)
                  : events)
              .map((e) => e.toOccasion(now))
              .toList(),
          textStyle: textStyle,
          textScaleFactor: textScaleFactor,
          dayParts: widget.dayParts,
          timepillarSide: TimepillarSide.right,
          measures: measures,
          topMargin: topMargin,
          bottomMargin: bottomMargin,
          showCategoryColor: showCategoryColor,
        );

        // Anchor is the starting point of the central sliver (timepillar).
        // horizontalAnchor is where the left side of the timepillar needs to be
        // in parts of the screen to make it centralized.
        return LayoutBuilder(
          builder: (context, boxConstraints) {
            final maxWidth = boxConstraints.maxWidth;
            final categoryMinWidth =
                (maxWidth - measures.timePillarTotalWidth) / 2;
            final timePillarPercentOfTotalScreen =
                (measures.timePillarTotalWidth / 2) / maxWidth;
            final horizontalAnchor = widget.showCategories
                ? 0.5 - timePillarPercentOfTotalScreen
                : 0.0;
            final tsHeight =
                measures.timePillarHeight + topMargin + bottomMargin;
            final calendarHeight =
                max(tsHeight, max(leftBoardData.heigth, rightBoardData.heigth));
            final height = max(calendarHeight, boxConstraints.maxHeight);
            return RefreshIndicator(
              onRefresh: refresh,
              notificationPredicate: (scrollNotification) =>
                  widget.scrollToTimeOffset &&
                  defaultScrollNotificationPredicate(scrollNotification),
              child: Container(
                key: TestKey.calendarBackgroundColor,
                color: interval.intervalPart == IntervalPart.night
                    ? TimepillarCalendar.nightBackgroundColor
                    : Theme.of(context).scaffoldBackgroundColor,
                child: ScrollArrows.all(
                  upCollapseMargin: topMargin,
                  downCollapseMargin: bottomMargin,
                  horizontalController: horizontalScrollController,
                  verticalController: verticalScrollController,
                  child: NotificationListener<ScrollNotification>(
                    onNotification:
                        enableScrollNotification ? onScrollNotification : null,
                    child: SingleChildScrollView(
                      controller: verticalScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: LimitedBox(
                        maxHeight: height,
                        child: BlocBuilder<ClockBloc, DateTime>(
                          builder: (context, now) => Stack(
                            children: <Widget>[
                              ...np.map((p) {
                                return Positioned(
                                  top: p.start,
                                  child: SizedBox(
                                    width: boxConstraints.maxWidth,
                                    height: p.length,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: TimepillarCalendar
                                              .nightBackgroundColor),
                                    ),
                                  ),
                                );
                              }),
                              if (widget.displayHourLines)
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
                                BlocBuilder<ClockBloc, DateTime>(
                                  builder: (context, now) {
                                    if (now.inRangeWithInclusiveStart(
                                        startDate: measures.interval.start,
                                        endDate: measures.interval.end)) {
                                      return Timeline(
                                        now: now,
                                        width: boxConstraints.maxWidth,
                                        offset:
                                            measures.topOffset(now) - topMargin,
                                        measures: measures,
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
                                  if (widget.showCategories)
                                    SliverToBoxAdapter(
                                      child: TimepillarBoard(
                                        leftBoardData,
                                        categoryMinWidth: categoryMinWidth,
                                        timepillarWidth:
                                            measures.cardTotalWidth,
                                        textStyle: textStyle,
                                      ),
                                    ),
                                  SliverTimePillar(
                                    key: center,
                                    child: BlocBuilder<MemoplannerSettingBloc,
                                        MemoplannerSettingsState>(
                                      buildWhen: (previous, current) =>
                                          previous.timepillar12HourFormat !=
                                              current.timepillar12HourFormat ||
                                          previous.columnOfDots !=
                                              current.columnOfDots,
                                      builder: (context, memoSettings) =>
                                          TimePillar(
                                        interval: interval,
                                        dayOccasion:
                                            widget.timepillarState.occasion,
                                        use12h:
                                            memoSettings.timepillar12HourFormat,
                                        nightParts: np,
                                        dayParts: widget.dayParts,
                                        columnOfDots: memoSettings.columnOfDots,
                                        topMargin: topMargin,
                                        measures: measures,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: TimepillarBoard(
                                      rightBoardData,
                                      categoryMinWidth: categoryMinWidth,
                                      timepillarWidth: measures.cardTotalWidth,
                                      textStyle: textStyle,
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
                ),
              ),
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
        animateTo(0,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
      prevScroll = currentScroll;
    });
  }
}

class NightPart {
  final double start, length;

  NightPart(this.start, this.length);
}
