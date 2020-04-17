import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/calendar/all.dart';

import 'all.dart';

class TimePillarCalendar extends StatefulWidget {
  final ActivitiesOccasionLoaded state;
  final CalendarViewState calendarViewState;
  final DateTime now;

  const TimePillarCalendar({
    Key key,
    @required this.state,
    @required this.calendarViewState,
    @required this.now,
  }) : super(key: key);

  @override
  _TimePillarCalendarState createState() => _TimePillarCalendarState();
}

class _TimePillarCalendarState extends State<TimePillarCalendar> {
  ScrollController verticalScrollController;
  ScrollController horizontalScrollController;

  final Key center = Key('center');
  double categoryLeftMinWidth, categoryRightMinWidth;
  @override
  void initState() {
    final scrollOffset = widget.state.isToday
        ? timeToPixelDistance(widget.now) - hourHeigt * 2
        : scrollHeight * (8 / 24 /* 8th hour */);
    verticalScrollController =
        ScrollController(initialScrollOffset: scrollOffset);

    horizontalScrollController = ScrollController();
    if (widget.state.isToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          BlocProvider.of<ScrollPositionBloc>(context)
              .add(ListViewRenderComplete(verticalScrollController)));
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    categoryRightMinWidth =
        MediaQuery.of(context).size.width - timePillarTotalWidth;
    categoryLeftMinWidth = categoryRightMinWidth / 2;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => horizontalScrollController.jumpTo(-categoryLeftMinWidth));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: <Widget>[
              SingleChildScrollView(
                controller: verticalScrollController,
                child: LimitedBox(
                  maxHeight: scrollHeight,
                  child: BlocBuilder<ClockBloc, DateTime>(
                    builder: (context, now) => Stack(
                      children: <Widget>[
                        if (widget.state.isToday)
                          Timeline(
                            now: now,
                            width: boxConstraints.maxWidth,
                          ),
                        CustomScrollView(
                          center: center,
                          scrollDirection: Axis.horizontal,
                          controller: horizontalScrollController,
                          slivers: <Widget>[
                            category(
                              CategoryLeft(
                                  expanded: widget
                                      .calendarViewState.expandLeftCategory),
                              height: boxConstraints.maxHeight,
                              sliver: ActivityBoard(
                                category: Category.left,
                                activities: widget.state.activities.where(
                                  (ao) =>
                                      ao.activity.category != Category.right,
                                ),
                                categoryMinWidth: categoryLeftMinWidth,
                              ),
                            ),
                            SliverTimePillar(
                              key: center,
                              child: TimePillar(
                                day: widget.state.day,
                                dayOccasion: widget.state.occasion,
                                now: now,
                              ),
                            ),
                            category(
                              CategoryRight(
                                  expanded: widget
                                      .calendarViewState.expandRightCategory),
                              height: boxConstraints.maxHeight,
                              sliver: ActivityBoard(
                                activities: widget.state.activities.where(
                                  (ao) =>
                                      ao.activity.category == Category.right,
                                ),
                                categoryMinWidth: categoryRightMinWidth,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ArrowLeft(controller: horizontalScrollController),
              ArrowUp(controller: verticalScrollController),
              ArrowRight(controller: horizontalScrollController),
              ArrowDown(controller: verticalScrollController),
            ],
          );
        },
      );

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

class ActivityBoard extends StatelessWidget {
  const ActivityBoard({
    Key key,
    @required this.categoryMinWidth,
    @required this.activities,
    this.category = Category.right,
  }) : super(key: key);

  final double categoryMinWidth;
  final Iterable<ActivityOccasion> activities;
  final int category;
  bool get right => category == Category.right;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: activities
            .map<Widget>(
          (ao) => Positioned(
            right: right ? null : 0,
            top: timeToPixelDistance(ao.activity.start),
            child: ActivityTimepillarCard(
              activityOccasion: ao,
            ),
          ),
        )
            .followedBy([Container(width: categoryMinWidth)]).toList(),
      ),
    );
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
