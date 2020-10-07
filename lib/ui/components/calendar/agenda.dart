import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

class Agenda extends StatefulWidget {
  final ActivitiesOccasionLoaded state;

  const Agenda({Key key, @required this.state}) : super(key: key);

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  ActivitiesBloc _activitiesBloc;
  ScrollPositionBloc _scrollPositionBloc;
  final center = GlobalKey();
  final todayScrollOffset = 10.0;
  var scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);
    _scrollPositionBloc = BlocProvider.of<ScrollPositionBloc>(context);

    if (widget.state.isToday) {
      if (widget.state.pastActivities.isNotEmpty) {
        scrollController = ScrollController(
          initialScrollOffset: -todayScrollOffset,
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
    final topMargin = 8.0;
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
                physics: AlwaysScrollableScrollPhysics(),
                slivers: (state.activities.isEmpty &&
                        state.fullDayActivities.isEmpty)
                    ? <Widget>[
                        SliverPadding(
                          key: center,
                          padding: const EdgeInsets.only(top: 24.0),
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
                        )
                      ]
                    : [
                        SliverPadding(padding: EdgeInsets.only(top: topMargin)),
                        SliverActivityList(
                          state.isToday
                              ? state.pastActivities
                                  .reversed // Reversed because slivers before center are called in reverse order
                                  .toList()
                              : state.pastActivities,
                        ),
                        SliverActivityList(state.notPastActivities,
                            key: center),
                        SliverPadding(padding: EdgeInsets.only(top: topMargin)),
                      ],
              ),
            ),
          ),
          ArrowUp(
            controller: scrollController,
            collapseMargin: topMargin,
          ),
          ArrowDown(
            controller: scrollController,
            collapseMargin: topMargin + todayScrollOffset,
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() {
    _activitiesBloc.add(LoadActivities());
    return _activitiesBloc
        .firstWhere((s) => s is! ActivitiesReloadning && s is ActivitiesLoaded);
  }

  bool _onScrollNotification(ScrollNotification scrollNotification) {
    _scrollPositionBloc
        .add(ScrollPositionUpdated(scrollNotification.metrics.pixels));
    return false;
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
