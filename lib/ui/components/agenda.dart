import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/ui/components.dart';

class Agenda extends StatefulWidget {
  const Agenda({
    Key key,
    @required this.cardHeight,
    @required ScrollController scrollController,
    @required this.currentActivityKey,
  })  : _scrollController = scrollController,
        super(key: key);

  final double cardHeight;
  final ScrollController _scrollController;
  final GlobalKey<State<StatefulWidget>> currentActivityKey;

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
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              BlocProvider.of<ScrollPositionBloc>(context)
                  .add(ListViewRenderComplete()));
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
                      onNotification: _onScrollNotification,
                      child: Scrollbar(
                        child: ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(), // https://github.com/flutter/flutter/issues/22180
                          itemExtent: widget.cardHeight,
                          controller: widget._scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          itemCount: activities.length,
                          itemBuilder: (context, index) => ActivityCard(
                            activityOccasion: activities[index],
                            height: widget.cardHeight,
                            key: index == state.indexOfCurrentActivity
                                ? widget.currentActivityKey
                                : null,
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
