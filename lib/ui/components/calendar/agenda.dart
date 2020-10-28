import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

class Agenda extends StatefulWidget {
  static const topPadding = 60.0, bottomPadding = 125.0;

  final ActivitiesOccasionLoaded state;
  final CalendarViewState calendarViewState;

  const Agenda({
    Key key,
    @required this.state,
    @required this.calendarViewState,
  }) : super(key: key);

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  final center = GlobalKey();
  final todayScrollOffset = 10.0;
  var scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    if (widget.state.isToday) {
      if (widget.state.pastActivities.isNotEmpty) {
        scrollController = ScrollController(
          initialScrollOffset: -todayScrollOffset - Agenda.topPadding,
          keepScrollOffset: false,
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          BlocProvider.of<ScrollPositionBloc>(context)
              .add(ScrollViewRenderComplete(scrollController)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final todayFirstActivity = state.isToday && state.pastActivities.isEmpty;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final categoryLabelWidth =
            (boxConstraints.maxWidth - timePillarWidth) / 2;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                onNotification: state.isToday ? _onScrollNotification : null,
                child: CupertinoScrollbar(
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
                            padding:
                                const EdgeInsets.only(top: Agenda.topPadding),
                            sliver: SliverActivityList(
                              state.isToday
                                  ? state.pastActivities
                                      .reversed // Reversed because slivers before center are called in reverse order
                                      .toList()
                                  : state.pastActivities,
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
                collapseMargin: Agenda.bottomPadding + todayScrollOffset,
              ),
              CategoryLeft(
                maxWidth: categoryLabelWidth,
                expanded: widget.calendarViewState.expandLeftCategory,
              ),
              CategoryRight(
                maxWidth: categoryLabelWidth,
                expanded: widget.calendarViewState.expandRightCategory,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh() {
    context.bloc<PushBloc>().add(PushEvent('refresh'));
    return context
        .bloc<ActivitiesBloc>()
        .firstWhere((s) => s is! ActivitiesReloadning && s is ActivitiesLoaded);
  }

  bool _onScrollNotification(ScrollNotification scrollNotification) {
    context
        .bloc<ScrollPositionBloc>()
        .add(ScrollPositionUpdated(scrollNotification.metrics.pixels));
    return false;
  }
}

class SliverNoActivities extends StatelessWidget {
  const SliverNoActivities({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: Agenda.topPadding),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Tts(
            child: Text(
              Translator.of(context).translate.noActivities,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
      ),
    );
  }
}

class SliverActivityList extends StatelessWidget {
  final List<ActivityOccasion> activities;
  const SliverActivityList(
    this.activities, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      sliver: SliverFixedExtentList(
        itemExtent: ActivityCard.cardHeight + ActivityCard.cardMargin,
        delegate: SliverChildBuilderDelegate(
          (context, index) => ActivityCard(
            activityOccasion: activities[index],
            margin: ActivityCard.cardMargin / 2,
          ),
          childCount: activities.length,
        ),
      ),
    );
  }
}
