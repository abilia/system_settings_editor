import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimePillarCalendar extends StatefulWidget {
  final ActivitiesOccasionLoaded activityState;
  final CalendarViewState calendarViewState;
  final MemoplannerSettingsState memoplannerSettingsState;
  final DateTime now;

  const TimePillarCalendar({
    Key key,
    @required this.activityState,
    @required this.calendarViewState,
    @required this.memoplannerSettingsState,
    @required this.now,
  }) : super(key: key);

  @override
  _TimePillarCalendarState createState() => _TimePillarCalendarState();
}

class _TimePillarCalendarState extends State<TimePillarCalendar> {
  ScrollPositionBloc _scrollPositionBloc;
  ScrollController verticalScrollController;
  ScrollController horizontalScrollController;
  final Key center = Key('center');

  @override
  void initState() {
    _scrollPositionBloc = BlocProvider.of<ScrollPositionBloc>(context);
    final scrollOffset = widget.activityState.isToday
        ? timeToPixelDistanceHour(widget.now) - hourHeigt * 2
        : hourHeigt * 8; // 8th hour
    verticalScrollController =
        ScrollController(initialScrollOffset: scrollOffset);

    horizontalScrollController = SnapToCenterScrollController();
    if (widget.activityState.isToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          BlocProvider.of<ScrollPositionBloc>(context)
              .add(ScrollViewRenderComplete(verticalScrollController)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final categoryMinWidth = (screenWidth - timePillarTotalWidth) / 2;

    final textStyle = Theme.of(context).textTheme.caption;
    final textScaleFactor = mediaData.textScaleFactor;
    final leftBoardData = ActivityBoard.positionTimepillarCards(
      widget.activityState.activities
          .where((ao) => ao.activity.category != Category.right)
          .toList(),
      textStyle,
      textScaleFactor,
      widget.activityState.day,
    );
    final rightBoardData = ActivityBoard.positionTimepillarCards(
      widget.activityState.activities
          .where((ao) => ao.activity.category == Category.right)
          .toList(),
      textStyle,
      textScaleFactor,
      widget.activityState.day,
    );
    final calendarHeight =
        max(timePillarHeight, max(leftBoardData.heigth, rightBoardData.heigth));

    // Anchor is the starting point of the central sliver (timepillar).
    // horizontalAnchor is where the left side of the timepillar needs to be in parts of the screen to make it centralized.
    final timePillarPercentOfTotalScreen =
        (timePillarTotalWidth / 2) / screenWidth;
    final horizontalAnchor = 0.5 - timePillarPercentOfTotalScreen;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Stack(
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification:
                  widget.activityState.isToday ? _onScrollNotification : null,
              child: SingleChildScrollView(
                controller: verticalScrollController,
                child: LimitedBox(
                  maxHeight: calendarHeight,
                  child: BlocBuilder<ClockBloc, DateTime>(
                    builder: (context, now) => Stack(
                      children: <Widget>[
                        if (widget.activityState.isToday)
                          Timeline(
                            width: boxConstraints.maxWidth,
                          ),
                        CustomScrollView(
                          anchor: horizontalAnchor,
                          center: center,
                          scrollDirection: Axis.horizontal,
                          controller: horizontalScrollController,
                          slivers: <Widget>[
                            if (widget.memoplannerSettingsState.showCategories)
                              category(
                                CategoryLeft(
                                  expanded: widget
                                      .calendarViewState.expandLeftCategory,
                                  settingsState:
                                      widget.memoplannerSettingsState,
                                ),
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
                                day: widget.activityState.day,
                                dayOccasion: widget.activityState.occasion,
                              ),
                            ),
                            if (widget.memoplannerSettingsState.showCategories)
                              category(
                                CategoryRight(
                                  expanded: widget
                                      .calendarViewState.expandRightCategory,
                                  settingsState:
                                      widget.memoplannerSettingsState,
                                ),
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
        );
      },
    );
  }

  bool _onScrollNotification(ScrollNotification scrollNotification) {
    _scrollPositionBloc
        .add(ScrollPositionUpdated(scrollNotification.metrics.pixels));
    return false;
  }

  Widget category(Widget category, {Widget sliver, double height}) =>
      SliverOverlay(
        height: height,
        overlay: ScrollTranslated(
          controller: verticalScrollController,
          child: category,
        ),
        sliver: sliver,
      );
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
