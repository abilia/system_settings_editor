import 'dart:math';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimepillarCalendar extends StatelessWidget {
  static const nightBackgroundColor = AbiliaColors.black90;
  final EventsLoaded eventState;
  final DayCalendarType type;

  const TimepillarCalendar({
    Key? key,
    required this.eventState,
    required this.type,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.dayParts != current.dayParts ||
          previous.displayTimeline != current.displayTimeline ||
          previous.showCategories != current.showCategories ||
          previous.displayHourLines != current.displayHourLines,
      builder: (context, memoplannerSettingsState) {
        if (type == DayCalendarType.oneTimepillar) {
          return BlocBuilder<TimepillarCubit, TimepillarState>(
            builder: (context, timepillarState) => OneTimepillarCalendar(
              key: ValueKey(timepillarState.timepillarInterval),
              timepillarState: timepillarState,
              dayParts: memoplannerSettingsState.dayParts,
              displayTimeline: memoplannerSettingsState.displayTimeline,
              showCategories: memoplannerSettingsState.showCategories,
              displayHourLines: memoplannerSettingsState.displayHourLines,
              eventState: eventState,
            ),
          );
        }
        return TwoTimepillarCalendar(
          eventState: eventState,
          showCategories: memoplannerSettingsState.showCategories,
          displayHourLines: memoplannerSettingsState.displayHourLines,
          displayTimeline: memoplannerSettingsState.displayTimeline,
          dayParts: memoplannerSettingsState.dayParts,
        );
      },
    );
  }
}

class OneTimepillarCalendar extends StatefulWidget {
  final EventsLoaded eventState;
  final TimepillarState timepillarState;
  final bool showCategories,
      displayHourLines,
      displayTimeline,
      showCategoryLabels,
      scrollToTimeOffset;
  final DayParts dayParts;
  final double topMargin, bottomMargin;

  OneTimepillarCalendar({
    Key? key,
    required this.eventState,
    required this.timepillarState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
    this.scrollToTimeOffset = true,
    double? topMargin,
    double? bottomMargin,
    bool? showCategoryLabels,
  })  : showCategoryLabels = showCategoryLabels ?? showCategories,
        topMargin = topMargin ?? layout.timePillar.topMargin,
        bottomMargin = bottomMargin ?? layout.timePillar.bottomMargin,
        super(key: key);

  @override
  _OneTimepillarCalendarState createState() => _OneTimepillarCalendarState();
}

class _OneTimepillarCalendarState extends State<OneTimepillarCalendar>
    with CalendarStateMixin {
  late final ScrollController verticalScrollController;
  late final ScrollController horizontalScrollController;
  final Key center = const Key('center');

  bool get enableScrollNotification =>
      widget.eventState.isToday && widget.scrollToTimeOffset;
  bool get showTimeLine => widget.eventState.isToday && widget.displayTimeline;
  TimepillarState get ts => widget.timepillarState;
  double get topMargin => widget.topMargin;
  double get bottomMargin => widget.topMargin;

  TimepillarInterval get interval => widget.timepillarState.timepillarInterval;

  @override
  void initState() {
    super.initState();
    verticalScrollController = widget.scrollToTimeOffset
        ? _timeOffsetVerticalScroll()
        : ScrollController();
    horizontalScrollController = SnapToCenterScrollController();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => context.read<ScrollPositionBloc>().scrollViewRenderComplete(
            verticalScrollController,
            createdTime: context.read<ClockBloc>().state,
          ),
    );
  }

  ScrollController _timeOffsetVerticalScroll() {
    final now = context.read<ClockBloc>().state;
    final scrollOffset = widget.eventState.isToday
        ? timeToPixels(now.hour, now.minute, ts.dotDistance) -
            ts.hourHeight * 2 -
            hoursToPixels(interval.startTime.hour, ts.dotDistance)
        : ts.hourHeight * widget.dayParts.morning.inHours;
    return ScrollController(initialScrollOffset: max(scrollOffset, 0));
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);

    final textTheme = Theme.of(context).textTheme.caption ?? caption;
    final fontSize = textTheme.fontSize!;
    final textStyle = textTheme.copyWith(fontSize: fontSize * ts.zoom);
    final textScaleFactor = mediaData.textScaleFactor;
    final events = interval.getForInterval(widget.eventState.events);
    final np = interval.intervalPart == IntervalPart.dayAndNight
        ? nightParts(widget.dayParts, ts, topMargin)
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
          timepillarState: ts,
          topMargin: topMargin,
          bottomMargin: bottomMargin,
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
          timepillarState: ts,
          topMargin: topMargin,
          bottomMargin: bottomMargin,
        );

        // Anchor is the starting point of the central sliver (timepillar).
        // horizontalAnchor is where the left side of the timepillar needs to be
        // in parts of the screen to make it centralized.
        return LayoutBuilder(
          builder: (context, boxConstraints) {
            final maxWidth = boxConstraints.maxWidth;
            final categoryMinWidth = (maxWidth - ts.timePillarTotalWidth) / 2;
            final timePillarPercentOfTotalScreen =
                (ts.timePillarTotalWidth / 2) / maxWidth;
            final horizontalAnchor = widget.showCategories
                ? 0.5 - timePillarPercentOfTotalScreen
                : 0.0;
            final tsHeight = ts.timePillarHeight + topMargin + bottomMargin;
            final calendarHeight =
                max(tsHeight, max(leftBoardData.heigth, rightBoardData.heigth));
            final height = max(calendarHeight, boxConstraints.maxHeight);
            return RefreshIndicator(
              onRefresh: refresh,
              notificationPredicate: (scrollNotification) =>
                  widget.scrollToTimeOffset &&
                  defaultScrollNotificationPredicate(scrollNotification),
              child: Container(
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
                                    hourHeight: ts.hourHeight,
                                  ),
                                ),
                              if (showTimeLine)
                                BlocBuilder<ClockBloc, DateTime>(
                                  builder: (context, now) {
                                    if (now.inRangeWithInclusiveStart(
                                        startDate:
                                            ts.timepillarInterval.startTime,
                                        endDate:
                                            ts.timepillarInterval.endTime)) {
                                      return Timeline(
                                        now: now,
                                        width: boxConstraints.maxWidth,
                                        offset: ts.topOffset(now) - topMargin,
                                        timepillarState: ts,
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
                                    category(
                                      widget.showCategoryLabels
                                          ? const LeftCategory()
                                          : null,
                                      height: boxConstraints.maxHeight,
                                      sliver: SliverToBoxAdapter(
                                        child: TimepillarBoard(
                                          leftBoardData,
                                          categoryMinWidth: categoryMinWidth,
                                          timepillarWidth: ts.cardTotalWidth,
                                          textStyle: textStyle,
                                        ),
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
                                        dayOccasion: widget.eventState.occasion,
                                        use12h:
                                            memoSettings.timepillar12HourFormat,
                                        nightParts: np,
                                        dayParts: widget.dayParts,
                                        columnOfDots: memoSettings.columnOfDots,
                                        topMargin: topMargin,
                                        timePillarState: ts,
                                      ),
                                    ),
                                  ),
                                  category(
                                    widget.showCategoryLabels
                                        ? const RightCategory()
                                        : null,
                                    height: boxConstraints.maxHeight,
                                    sliver: SliverToBoxAdapter(
                                      child: TimepillarBoard(
                                        rightBoardData,
                                        categoryMinWidth: categoryMinWidth,
                                        timepillarWidth: ts.cardTotalWidth,
                                        textStyle: textStyle,
                                      ),
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
    TimepillarState ts,
    double topMargin,
  ) {
    final interval = ts.timepillarInterval;
    final intervalDay = interval.startTime.onlyDays();
    return <NightPart>[
      if (interval.startTime.isBefore(intervalDay.add(dayParts.morning)))
        NightPart(
          0,
          hoursToPixels(
                  intervalDay.add(dayParts.morning).hour, ts.dotDistance) +
              topMargin,
        ),
      if (interval.endTime.isAfter(intervalDay.add(dayParts.night)))
        NightPart(
            hoursToPixels(
                    intervalDay.add(dayParts.night).hour, ts.dotDistance) +
                topMargin,
            hoursToPixels(
                interval.endTime.hour == 0 ? 24 : interval.endTime.hour,
                ts.dotDistance))
    ];
  }

  Widget category(
    Widget? category, {
    required Widget sliver,
    required double height,
  }) =>
      category != null
          ? SliverOverlay(
              height: height,
              overlay: ScrollTranslated(
                controller: verticalScrollController,
                child: category,
              ),
              sliver: sliver,
            )
          : sliver;
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

class ScrollTranslated extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  const ScrollTranslated({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);
  @override
  _ScrollTranslated createState() => _ScrollTranslated();
}

class _ScrollTranslated extends State<ScrollTranslated> {
  late double scrollOffset;
  @override
  void initState() {
    widget.controller.addListener(listener);
    scrollOffset =
        widget.controller.hasClients ? widget.controller.offset : 0.0;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0.0, scrollOffset), child: widget.child);
  }

  void listener() {
    if (widget.controller.offset != scrollOffset) {
      setState(() => scrollOffset = max(widget.controller.offset, 0));
    }
  }
}
