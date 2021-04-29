import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';

class Agenda extends StatefulWidget {
  static final topPadding = 60.0.s,
      bottomPadding = 125.0.s,
      categoryWidth = 42.0.s;

  final ActivitiesOccasionLoaded activityState;
  final CalendarViewState calendarViewState;

  const Agenda({
    Key key,
    @required this.activityState,
    @required this.calendarViewState,
  }) : super(key: key);

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> with CalendarStateMixin {
  final center = GlobalKey();
  var scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    if (widget.activityState.isToday) {
      if (widget.activityState.pastActivities.isNotEmpty) {
        scrollController = ScrollController(
          initialScrollOffset: -Agenda.topPadding,
          keepScrollOffset: false,
        );
      }
    }
    _addScrollViewRenderCompleteCallback();
    super.initState();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _addScrollViewRenderCompleteCallback();
  }

  void _addScrollViewRenderCompleteCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<ScrollPositionBloc>(context)
          .add(ScrollViewRenderComplete(scrollController));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.activityState;
    final todayFirstActivity = state.isToday && state.pastActivities.isEmpty;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final categoryLabelWidth =
            (boxConstraints.maxWidth.s - Agenda.categoryWidth) / 2;
        return RefreshIndicator(
          onRefresh: refresh,
          child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            builder: (context, memoplannerSettingsState) => Stack(
              children: <Widget>[
                NotificationListener<ScrollNotification>(
                  onNotification: state.isToday ? onScrollNotification : null,
                  child: AbiliaScrollBar(
                    controller: scrollController,
                    child: CustomScrollView(
                      center: state.isToday ? center : null,
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (state.activities.isEmpty &&
                            state.fullDayActivities.isEmpty)
                          SliverNoActivities(key: center)
                        else ...[
                          if (!todayFirstActivity)
                            SliverPadding(
                              padding: EdgeInsets.only(top: Agenda.topPadding),
                              sliver: SliverActivityList(
                                state.pastActivities,
                                reversed: state.isToday,
                                lastMargin: _lastPastPadding(
                                  state.pastActivities,
                                  state.notPastActivities,
                                ),
                                showCategories:
                                    memoplannerSettingsState.showCategories,
                              ),
                            ),
                          SliverPadding(
                            key: center,
                            padding: EdgeInsets.only(
                              top: todayFirstActivity ? Agenda.topPadding : 0.0,
                              bottom: Agenda.bottomPadding,
                            ),
                            sliver: SliverActivityList(
                              state.notPastActivities,
                              showCategories:
                                  memoplannerSettingsState.showCategories,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ArrowUp(
                  controller: scrollController,
                  collapseMargin: Agenda.topPadding,
                ),
                ArrowDown(
                  controller: scrollController,
                  collapseMargin: Agenda.bottomPadding,
                ),
                if (memoplannerSettingsState.showCategories) ...[
                  CategoryLeft(
                    maxWidth: categoryLabelWidth,
                    categoryName: memoplannerSettingsState.leftCategoryName,
                    expanded: widget.calendarViewState.expandLeftCategory,
                  ),
                  CategoryRight(
                    maxWidth: categoryLabelWidth,
                    categoryName: memoplannerSettingsState.rightCategoryName,
                    expanded: widget.calendarViewState.expandRightCategory,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  double _lastPastPadding(
    List<ActivityOccasion> notPastActivities,
    List<ActivityOccasion> pastActivities,
  ) =>
      pastActivities.isEmpty || notPastActivities.isEmpty
          ? 0.0
          : pastActivities.first.activity.category ==
                  notPastActivities.first.activity.category
              ? ActivityCard.cardMarginSmall
              : ActivityCard.cardMarginLarge;
}

class SliverNoActivities extends StatelessWidget {
  const SliverNoActivities({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 96.s),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Tts(
            child: Text(
              Translator.of(context).translate.noActivities,
              style: abiliaTextTheme.bodyText1
                  .copyWith(color: AbiliaColors.black75),
            ),
          ),
        ),
      ),
    );
  }
}

class SliverActivityList extends StatelessWidget {
  final List<ActivityOccasion> activities;
  // Reversed because slivers before center are called in reverse order
  final bool reversed;
  final double lastMargin;
  final int _maxIndex;
  final bool showCategories;
  const SliverActivityList(
    this.activities, {
    this.reversed = false,
    this.lastMargin = 0.0,
    Key key,
    @required this.showCategories,
  })  : _maxIndex = activities.length - 1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.s),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (reversed) index = _maxIndex - index;
            return ActivityCard(
              activityOccasion: activities[index],
              bottomPadding: showCategories
                  ? _padding(index)
                  : ActivityCard.cardMarginSmall,
              showCategories: showCategories,
            );
          },
          childCount: activities.length,
        ),
      ),
    );
  }

  double _padding(int index) => index >= _maxIndex
      ? lastMargin
      : activities[index].activity.category ==
              activities[index + 1].activity.category
          ? ActivityCard.cardMarginSmall
          : ActivityCard.cardMarginLarge;
}
