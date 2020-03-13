import 'dart:math';

import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';

class Agenda extends StatefulWidget {
  final double cardHeight;
  final double cardMargin;
  final ActivitiesOccasionLoaded state;

  const Agenda({
    Key key,
    @required this.state,
    @required this.cardHeight,
    @required this.cardMargin,
  }) : super(key: key);

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  ActivitiesBloc _activitiesBloc;
  ScrollPositionBloc _scrollPositionBloc;

  @override
  void initState() {
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);
    _scrollPositionBloc = BlocProvider.of<ScrollPositionBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final scrollController = ScrollController(
        initialScrollOffset: max(
            state.indexOfCurrentActivity *
                (widget.cardHeight + widget.cardMargin),
            0),
        keepScrollOffset: false);
    if (state.isToday) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          BlocProvider.of<ScrollPositionBloc>(context)
              .add(ListViewRenderComplete(scrollController)));
    }
    final activities = state.activities;
    final fullDayActivities = state.fullDayActivities;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: NotificationListener<ScrollNotification>(
          onNotification: state.isToday ? _onScrollNotification : null,
          child: Scrollbar(
            child: activities.isEmpty && fullDayActivities.isEmpty
                ? ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Center(
                          child: Text(
                            Translator.of(context).translate.noActivities,
                            style: Theme.of(context).textTheme.body2,
                          ),
                        ),
                      )
                    ],
                  )
                : ListView.builder(
                    itemExtent: widget.cardHeight + widget.cardMargin,
                    controller: state.isToday ? scrollController : null,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: activities.length,
                    itemBuilder: (context, index) => ActivityCard(
                      activityOccasion: activities[index],
                      cardMargin: widget.cardMargin / 2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    _activitiesBloc.add(LoadActivities());
    return _activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
  }

  bool _onScrollNotification(ScrollNotification scrollNotification) {
    _scrollPositionBloc
        .add(ScrollPositionUpdated(scrollNotification.metrics.pixels));
    return false;
  }
}
