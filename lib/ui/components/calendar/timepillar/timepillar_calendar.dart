import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimePillarCalendar extends StatefulWidget {
  static const topMargin = 30.0;
  static const bottomMargin = 10.0;
  static const topPadding = 2 * hourPadding;
  final ActivitiesOccasionLoaded activityState;
  final CalendarViewState calendarViewState;
  final MemoplannerSettingsState memoplannerSettingsState;
  final TimepillarInterval timepillarInterval;

  const TimePillarCalendar({
    Key key,
    @required this.activityState,
    @required this.calendarViewState,
    @required this.memoplannerSettingsState,
    @required this.timepillarInterval,
  }) : super(key: key);

  @override
  _TimePillarCalendarState createState() => _TimePillarCalendarState();
}

class _TimePillarCalendarState extends State<TimePillarCalendar>
    with CalendarStateMixin {
  ScrollController verticalScrollController;
  ScrollController horizontalScrollController;
  final Key center = Key('center');

  MemoplannerSettingsState get memoSettings => widget.memoplannerSettingsState;
  bool get isToday => widget.activityState.isToday;
  bool get showTimeLine => isToday && memoSettings.displayTimeline;
  bool get showCategories => memoSettings.showCategories;
  bool get showHourLines => memoSettings.displayHourLines;
  DateTime get day => widget.activityState.day;
  List<ActivityOccasion> get activities => widget.activityState.activities;
  CalendarViewState get viewState => widget.calendarViewState;
  TimepillarInterval get interval => widget.timepillarInterval;

  @override
  void initState() {
    initVerticalScroll();
    horizontalScrollController = SnapToCenterScrollController();
    if (widget.activityState.isToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          BlocProvider.of<ScrollPositionBloc>(context)
              .add(ScrollViewRenderComplete(verticalScrollController)));
    }
    super.initState();
  }

  // @override
  // void didUpdateWidget(TimePillarCalendar tpc) {
  //   super.didUpdateWidget(tpc);
  //   initVerticalScroll();
  // }

  void initVerticalScroll() {
    final now = context.read<ClockBloc>().state;
    final scrollOffset = widget.activityState.isToday
        ? timeToPixels(now.hour, now.minute) -
            hourHeigt * 2 -
            hoursToPixels(interval.startTime.hour)
        : hourHeigt * memoSettings.dayParts.morning.inHours;
    verticalScrollController =
        ScrollController(initialScrollOffset: max(scrollOffset, 0));
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final categoryMinWidth = (screenWidth - timePillarTotalWidth) / 2;

    final textStyle = Theme.of(context).textTheme.caption;
    final textScaleFactor = mediaData.textScaleFactor;
    final timepillarActivities = interval.getForInterval(activities);
    final leftBoardData = ActivityBoard.positionTimepillarCards(
      timepillarActivities
          .where((ao) => ao.activity.category != Category.right)
          .toList(),
      textStyle,
      textScaleFactor,
      interval,
      memoSettings.dayParts,
    );
    final rightBoardData = ActivityBoard.positionTimepillarCards(
      timepillarActivities
          .where((ao) => ao.activity.category == Category.right)
          .toList(),
      textStyle,
      textScaleFactor,
      interval,
      memoSettings.dayParts,
    );
    final calendarHeight = max(timePillarHeight(interval),
        max(leftBoardData.heigth, rightBoardData.heigth));

    final np = interval.intervalPart == IntervalPart.DAY_AND_NIGHT
        ? nightParts(widget.memoplannerSettingsState.dayParts, interval)
        : <NightPart>[];

    // Anchor is the starting point of the central sliver (timepillar).
    // horizontalAnchor is where the left side of the timepillar needs to be in parts of the screen to make it centralized.
    final timePillarPercentOfTotalScreen =
        (timePillarTotalWidth / 2) / screenWidth;
    final horizontalAnchor = 0.5 - timePillarPercentOfTotalScreen;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final height = max(calendarHeight, boxConstraints.maxHeight);
        return Container(
          color: interval.intervalPart == IntervalPart.NIGHT
              ? AbiliaColors.black90
              : Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                onNotification: isToday ? onScrollNotification : null,
                child: SingleChildScrollView(
                  controller: verticalScrollController,
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
                                      color: AbiliaColors.black90),
                                ),
                              ),
                            );
                          }),
                          if (showHourLines)
                            Padding(
                              padding: EdgeInsets.only(
                                  top: TimePillarCalendar.topMargin),
                              child: HourLines(
                                numberOfLines: interval.lengthInHours + 1,
                              ),
                            ),
                          if (showTimeLine)
                            Timeline(
                              width: boxConstraints.maxWidth,
                              offset: hoursToPixels(interval.startTime.hour) -
                                  TimePillarCalendar.topMargin,
                            ),
                          CustomScrollView(
                            anchor: horizontalAnchor,
                            center: center,
                            scrollDirection: Axis.horizontal,
                            controller: horizontalScrollController,
                            slivers: <Widget>[
                              category(
                                showCategories
                                    ? CategoryLeft(
                                        expanded: viewState.expandLeftCategory,
                                        settingsState: memoSettings,
                                      )
                                    : null,
                                height: boxConstraints.maxHeight,
                                sliver: SliverToBoxAdapter(
                                  child: ActivityBoard(
                                    leftBoardData,
                                    categoryMinWidth: categoryMinWidth,
                                  ),
                                ),
                              ),
                              SliverTimePillar(
                                key: center,
                                child: TimePillar(
                                  interval: interval,
                                  dayOccasion: widget.activityState.occasion,
                                  showTimeLine: showTimeLine,
                                  hourClockType:
                                      memoSettings.timepillarHourClockType,
                                  nightParts: np,
                                  dayParts: memoSettings.dayParts,
                                ),
                              ),
                              category(
                                showCategories
                                    ? CategoryRight(
                                        expanded: viewState.expandRightCategory,
                                        settingsState: memoSettings,
                                      )
                                    : null,
                                height: boxConstraints.maxHeight,
                                sliver: SliverToBoxAdapter(
                                  child: ActivityBoard(
                                    rightBoardData,
                                    categoryMinWidth: categoryMinWidth,
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
                collapseMargin: ActivityTimepillarCard.padding,
              ),
              ArrowUp(controller: verticalScrollController),
              ArrowRight(
                controller: horizontalScrollController,
                collapseMargin: ActivityTimepillarCard.padding,
              ),
              ArrowDown(controller: verticalScrollController),
            ],
          ),
        );
      },
    );
  }

  List<NightPart> nightParts(DayParts dayParts, TimepillarInterval interval) {
    final intervalDay = interval.startTime.onlyDays();
    final p = <NightPart>[];
    if (interval.startTime.isBefore(intervalDay.add(dayParts.morning))) {
      p.add(NightPart(
          0,
          hoursToPixels(intervalDay.add(dayParts.morning).hour) +
              TimePillarCalendar.topMargin));
    }
    if (interval.endTime.isAfter(intervalDay.add(dayParts.night))) {
      p.add(NightPart(
          hoursToPixels(intervalDay.add(dayParts.night).hour) +
              TimePillarCalendar.topMargin,
          hoursToPixels(
              interval.endTime.hour == 0 ? 24 : interval.endTime.hour)));
    }
    return p;
  }

  Widget category(Widget category, {Widget sliver, double height}) =>
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

  const ScrollTranslated({Key key, this.controller, this.child})
      : super(key: key);
  @override
  _ScrollTranslated createState() => _ScrollTranslated();
}

class _ScrollTranslated extends State<ScrollTranslated> {
  double scrollOffset;
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
