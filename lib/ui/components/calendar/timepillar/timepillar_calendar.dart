import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimepillarCalendar extends StatelessWidget {
  static final topMargin = 96.0.s;
  static final bottomMargin = 64.0.s;
  static const nightBackgroundColor = AbiliaColors.black90;
  final ActivitiesOccasionLoaded activityState;
  final DayCalendarType type;

  const TimepillarCalendar({
    Key? key,
    required this.activityState,
    required this.type,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimepillarBloc, TimepillarState>(
      builder: (context, timepillarState) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.dayParts != current.dayParts ||
            previous.displayTimeline != current.displayTimeline ||
            previous.showCategories != current.showCategories ||
            previous.displayHourLines != current.displayHourLines,
        builder: (context, memoplannerSettingsState) {
          if (type == DayCalendarType.one_timepillar) {
            return OneTimepillarCalendar(
              key: ValueKey(timepillarState.timepillarInterval),
              activityState: activityState,
              timepillarState: timepillarState,
              dayParts: memoplannerSettingsState.dayParts,
              displayTimeline: memoplannerSettingsState.displayTimeline,
              showCategories: memoplannerSettingsState.showCategories,
              displayHourLines: memoplannerSettingsState.displayHourLines,
            );
          }
          return TwoTimepillarCalendar(
            activityState: activityState,
            timepillarState: timepillarState,
            showCategories: memoplannerSettingsState.showCategories,
            displayHourLines: memoplannerSettingsState.displayHourLines,
            displayTimeline: memoplannerSettingsState.displayTimeline,
            dayParts: memoplannerSettingsState.dayParts,
            memoplannerSettingsState: memoplannerSettingsState,
          );
        },
      ),
    );
  }
}

class OneTimepillarCalendar extends StatefulWidget {
  final ActivitiesOccasionLoaded activityState;
  final TimepillarState timepillarState;
  final bool showCategories,
      displayHourLines,
      displayTimeline,
      showCategoryLabels;
  final DayParts dayParts;

  const OneTimepillarCalendar({
    Key? key,
    required this.activityState,
    required this.timepillarState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
    bool? showCategoryLabels,
  })  : showCategoryLabels = showCategoryLabels ?? showCategories,
        super(key: key);

  @override
  _OneTimepillarCalendarState createState() => _OneTimepillarCalendarState();
}

class _OneTimepillarCalendarState extends State<OneTimepillarCalendar>
    with CalendarStateMixin {
  late final ScrollController verticalScrollController;
  late final ScrollController horizontalScrollController;
  final Key center = Key('center');

  bool get isToday => widget.activityState.isToday;
  bool get showTimeLine => isToday && widget.displayTimeline;
  TimepillarState get ts => widget.timepillarState;

  List<ActivityOccasion> get activities => widget.activityState.activities;
  TimepillarInterval get interval => widget.timepillarState.timepillarInterval;

  @override
  void initState() {
    super.initState();
    verticalScrollController = _initVerticalScroll();
    horizontalScrollController = SnapToCenterScrollController();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => BlocProvider.of<ScrollPositionBloc>(context).add(
        ScrollViewRenderComplete(
          verticalScrollController,
          createdTime: context.read<ClockBloc>().state,
        ),
      ),
    );
  }

  ScrollController _initVerticalScroll() {
    final now = context.read<ClockBloc>().state;
    final scrollOffset = widget.activityState.isToday
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
    final fontSize = textTheme.fontSize ?? catptionFontSize;
    final textStyle = textTheme.copyWith(fontSize: fontSize * ts.zoom);
    final textScaleFactor = mediaData.textScaleFactor;
    final timepillarActivities = interval.getForInterval(activities);
    final leftBoardData = ActivityBoard.positionTimepillarCards(
      widget.showCategories
          ? timepillarActivities
              .where((ao) => ao.activity.category != Category.right)
              .toList()
          : <ActivityOccasion>[],
      textStyle,
      textScaleFactor,
      widget.dayParts,
      TimepillarSide.LEFT,
      ts,
    );
    final rightBoardData = ActivityBoard.positionTimepillarCards(
      widget.showCategories
          ? timepillarActivities
              .where((ao) => ao.activity.category == Category.right)
              .toList()
          : timepillarActivities,
      textStyle,
      textScaleFactor,
      widget.dayParts,
      TimepillarSide.RIGHT,
      ts,
    );
    final calendarHeight = max(
        timePillarHeight(ts), max(leftBoardData.heigth, rightBoardData.heigth));

    final np = interval.intervalPart == IntervalPart.DAY_AND_NIGHT
        ? nightParts(widget.dayParts, ts)
        : <NightPart>[];

    // Anchor is the starting point of the central sliver (timepillar).
    // horizontalAnchor is where the left side of the timepillar needs to be in parts of the screen to make it centralized.
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final maxWidth = boxConstraints.maxWidth;
        final categoryMinWidth = (maxWidth - ts.timePillarTotalWidth) / 2;
        final timePillarPercentOfTotalScreen =
            (ts.timePillarTotalWidth / 2) / maxWidth;
        final horizontalAnchor =
            widget.showCategories ? 0.5 - timePillarPercentOfTotalScreen : 0.0;
        final height = max(calendarHeight, boxConstraints.maxHeight);
        return RefreshIndicator(
          onRefresh: refresh,
          child: Container(
            color: interval.intervalPart == IntervalPart.NIGHT
                ? TimepillarCalendar.nightBackgroundColor
                : Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: <Widget>[
                NotificationListener<ScrollNotification>(
                  onNotification: isToday ? onScrollNotification : null,
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
                                    top: TimepillarCalendar.topMargin),
                                child: HourLines(
                                  numberOfLines: interval.lengthInHours + 1,
                                  hourHeight: ts.hourHeight,
                                ),
                              ),
                            if (showTimeLine)
                              Timeline(
                                width: boxConstraints.maxWidth,
                                offset: hoursToPixels(interval.startTime.hour,
                                        ts.dotDistance) -
                                    TimepillarCalendar.topMargin,
                                timepillarState: ts,
                              ),
                            CustomScrollView(
                              anchor: horizontalAnchor,
                              center: center,
                              scrollDirection: Axis.horizontal,
                              controller: horizontalScrollController,
                              slivers: <Widget>[
                                if (widget.showCategoryLabels)
                                  category(
                                    widget.showCategories
                                        ? LeftCategory()
                                        : null,
                                    height: boxConstraints.maxHeight,
                                    sliver: SliverToBoxAdapter(
                                      child: ActivityBoard(
                                        leftBoardData,
                                        categoryMinWidth: categoryMinWidth,
                                        timepillarWidth: ts.totalWidth,
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
                                      dayOccasion:
                                          widget.activityState.occasion,
                                      use12h:
                                          memoSettings.timepillar12HourFormat,
                                      nightParts: np,
                                      dayParts: widget.dayParts,
                                      columnOfDots: memoSettings.columnOfDots,
                                    ),
                                  ),
                                ),
                                category(
                                  widget.showCategoryLabels
                                      ? RightCategory()
                                      : null,
                                  height: boxConstraints.maxHeight,
                                  sliver: SliverToBoxAdapter(
                                    child: ActivityBoard(
                                      rightBoardData,
                                      categoryMinWidth: categoryMinWidth,
                                      timepillarWidth: ts.totalWidth,
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
                ArrowLeft(
                  controller: horizontalScrollController,
                  collapseMargin: ts.padding,
                ),
                ArrowUp(controller: verticalScrollController),
                ArrowRight(
                  controller: horizontalScrollController,
                  collapseMargin: ts.padding,
                ),
                ArrowDown(controller: verticalScrollController),
              ],
            ),
          ),
        );
      },
    );
  }

  List<NightPart> nightParts(DayParts dayParts, TimepillarState ts) {
    final interval = ts.timepillarInterval;
    final intervalDay = interval.startTime.onlyDays();
    return <NightPart>[
      if (interval.startTime.isBefore(intervalDay.add(dayParts.morning)))
        NightPart(
            0,
            hoursToPixels(
                    intervalDay.add(dayParts.morning).hour, ts.dotDistance) +
                TimepillarCalendar.topMargin),
      if (interval.endTime.isAfter(intervalDay.add(dayParts.night)))
        NightPart(
            hoursToPixels(
                    intervalDay.add(dayParts.night).hour, ts.dotDistance) +
                TimepillarCalendar.topMargin,
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
            duration: Duration(milliseconds: 200), curve: Curves.easeOut);
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
