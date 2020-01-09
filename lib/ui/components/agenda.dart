import 'dart:math';

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';

class Agenda extends StatefulWidget {
  final double cardHeight = 80.0;

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
    return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
      builder: (context, state) {
        if (state is ActivitiesOccasionLoaded) {
          final scrollController = ScrollController(
              initialScrollOffset:
                  max(state.indexOfCurrentActivity * widget.cardHeight, 0),
              keepScrollOffset: false);
          if (state.isToday) {
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                BlocProvider.of<ScrollPositionBloc>(context)
                    .add(ListViewRenderComplete(scrollController)));
          } else {
            BlocProvider.of<ScrollPositionBloc>(context)
                .add(WrongDaySelected());
          }
          final activities = state.activities;
          final fullDayActivities = state.fullDayActivities;
          return Column(
            children: <Widget>[
              if (fullDayActivities.isNotEmpty)
                Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).appBarTheme.color),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: fullDayActivities
                          .map((ao) => ActivityCard(
                              activityOccasion: ao, height: widget.cardHeight))
                          .toList(),
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: NotificationListener<ScrollNotification>(
                      onNotification:
                          state.isToday ? _onScrollNotification : null,
                      child: Scrollbar(
                        child: activities.isEmpty && fullDayActivities.isEmpty
                            ? ListView(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Center(
                                        child: Text(
                                      Translator.of(context)
                                          .translate
                                          .noActivities,
                                      style: Theme.of(context).textTheme.body2,
                                    )),
                                  )
                                ],
                              )
                            : ListView.builder(
                                itemExtent: widget.cardHeight,
                                controller:
                                    state.isToday ? scrollController : null,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                itemCount: activities.length,
                                itemBuilder: (context, index) => ActivityCard(
                                  activityOccasion: activities[index],
                                  height: widget.cardHeight,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      },
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
