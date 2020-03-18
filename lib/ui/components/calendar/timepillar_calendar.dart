import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/calendar/overlay/all.dart';

import 'all.dart';

class TimePillarCalendar extends StatefulWidget {
  final ActivitiesOccasionLoaded state;
  final CalendarViewState calendarViewState;

  const TimePillarCalendar({
    Key key,
    @required this.state,
    @required this.calendarViewState,
  }) : super(key: key);

  @override
  _TimePillarCalendarState createState() => _TimePillarCalendarState();
}

class _TimePillarCalendarState extends State<TimePillarCalendar> {
  ScrollController verticalScrollController;
  ScrollController horizontalScrollController;
  final Key center = Key('center');
  double categoryMinWidth;
  @override
  void initState() {
    verticalScrollController = ScrollController(
        initialScrollOffset: scrollHeight * (8 / 24 /* 8th hour */));
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
    categoryMinWidth =
        (MediaQuery.of(context).size.width - timePillarTotalWidth);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => horizontalScrollController.jumpTo(-categoryMinWidth / 2));
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

  Widget category(Widget category, {double height}) => SliverOverlay(
        height: height,
        overlay: ScrollTranslated(
          controller: verticalScrollController,
          child: category,
        ),
        sliver: SliverToBoxAdapter(
          child: Container(width: categoryMinWidth),
        ),
      );
}

class Timeline extends StatelessWidget {
  final DateTime now;
  final double width;
  const Timeline({
    Key key,
    @required this.now,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: transitionDuration,
      child: Container(
        width: width,
        height: 2,
        decoration: BoxDecoration(color: AbiliaColors.red),
      ),
      top: timeToPixelDistance(now),
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
