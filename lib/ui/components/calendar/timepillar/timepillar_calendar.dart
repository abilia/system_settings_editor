import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

const transitionDuration = Duration(seconds: 1);

class TimepillarCalendar extends StatelessWidget {
  static final topMargin = 30.0.s;
  static final bottomMargin = 10.0.s;
  static const nightBackgroundColor = AbiliaColors.black90;
  final ActivitiesOccasionLoaded activityState;
  final CalendarViewState calendarViewState;

  const TimepillarCalendar({
    Key key,
    this.activityState,
    this.calendarViewState,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimepillarBloc, TimepillarState>(
      builder: (context, state) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoplannerSettingsState) => _TimepillarCalendar(
          key: ValueKey(state.timepillarInterval),
          activityState: activityState,
          calendarViewState: calendarViewState,
          memoplannerSettingsState: memoplannerSettingsState,
          timepillarState: state,
        ),
      ),
    );
  }
}

class _TimepillarCalendar extends StatefulWidget {
  final ActivitiesOccasionLoaded activityState;
  final CalendarViewState calendarViewState;
  final MemoplannerSettingsState memoplannerSettingsState;
  final TimepillarState timepillarState;

  const _TimepillarCalendar({
    Key key,
    @required this.activityState,
    @required this.calendarViewState,
    @required this.memoplannerSettingsState,
    @required this.timepillarState,
  }) : super(key: key);

  @override
  _TimepillarCalendarState createState() => _TimepillarCalendarState();
}

class _TimepillarCalendarState extends State<_TimepillarCalendar>
    with CalendarStateMixin {
  ScrollController verticalScrollController;
  ScrollController horizontalScrollController;
  final Key center = Key('center');

  MemoplannerSettingsState get memoSettings => widget.memoplannerSettingsState;
  bool get isToday => widget.activityState.isToday;
  bool get showTimeLine => isToday && memoSettings.displayTimeline;
  bool get showCategories => memoSettings.showCategories;
  bool get showHourLines => memoSettings.displayHourLines;
  List<ActivityOccasion> get activities => widget.activityState.activities;
  CalendarViewState get viewState => widget.calendarViewState;
  TimepillarInterval get interval => widget.timepillarState.timepillarInterval;

  @override
  void initState() {
    initVerticalScroll();
    horizontalScrollController = SnapToCenterScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => BlocProvider.of<ScrollPositionBloc>(context).add(
        ScrollViewRenderComplete(
          verticalScrollController,
          createdTime: context.read<ClockBloc>().state,
        ),
      ),
    );
    super.initState();
  }

  void initVerticalScroll() {
    final now = context.read<ClockBloc>().state;
    final ts = context.read<TimepillarBloc>().state;
    final scrollOffset = widget.activityState.isToday
        ? timeToPixels(now.hour, now.minute, ts.dotDistance) -
            ts.hourHeight * 2 -
            hoursToPixels(interval.startTime.hour, ts.dotDistance)
        : ts.hourHeight * memoSettings.dayParts.morning.inHours;
    verticalScrollController =
        ScrollController(initialScrollOffset: max(scrollOffset, 0));
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.timepillarState;
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final categoryMinWidth = (screenWidth - ts.timePillarTotalWidth) / 2;

    final fontSize = Theme.of(context).textTheme.caption.fontSize;
    final textStyle = Theme.of(context)
        .textTheme
        .caption
        .copyWith(fontSize: fontSize * ts.zoom);
    final textScaleFactor = mediaData.textScaleFactor;
    final timepillarActivities = interval.getForInterval(activities);
    final leftBoardData = ActivityBoard.positionTimepillarCards(
      showCategories
          ? timepillarActivities
              .where((ao) => ao.activity.category != Category.right)
              .toList()
          : <ActivityOccasion>[],
      textStyle,
      textScaleFactor,
      memoSettings.dayParts,
      TimepillarSide.LEFT,
      ts,
    );
    final rightBoardData = ActivityBoard.positionTimepillarCards(
      showCategories
          ? timepillarActivities
              .where((ao) => ao.activity.category == Category.right)
              .toList()
          : timepillarActivities,
      textStyle,
      textScaleFactor,
      memoSettings.dayParts,
      TimepillarSide.RIGHT,
      ts,
    );
    final calendarHeight = max(
        timePillarHeight(ts), max(leftBoardData.heigth, rightBoardData.heigth));

    final np = interval.intervalPart == IntervalPart.DAY_AND_NIGHT
        ? nightParts(widget.memoplannerSettingsState.dayParts, ts)
        : <NightPart>[];

    // Anchor is the starting point of the central sliver (timepillar).
    // horizontalAnchor is where the left side of the timepillar needs to be in parts of the screen to make it centralized.
    final timePillarPercentOfTotalScreen =
        (ts.timePillarTotalWidth / 2) / screenWidth;
    final horizontalAnchor =
        showCategories ? 0.5 - timePillarPercentOfTotalScreen : 0.0;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
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
                            if (showHourLines)
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
                                if (showCategories)
                                  category(
                                    showCategories
                                        ? CategoryLeft(
                                            expanded:
                                                viewState.expandLeftCategory,
                                            settingsState: memoSettings,
                                          )
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
                                  child: TimePillar(
                                    interval: interval,
                                    dayOccasion: widget.activityState.occasion,
                                    showTimeLine: showTimeLine,
                                    use12h: memoSettings.timepillar12HourFormat,
                                    nightParts: np,
                                    dayParts: memoSettings.dayParts,
                                    columnOfDots: memoSettings.columnOfDots,
                                  ),
                                ),
                                category(
                                  showCategories
                                      ? CategoryRight(
                                          expanded:
                                              viewState.expandRightCategory,
                                          settingsState: memoSettings,
                                        )
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
