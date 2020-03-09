import 'dart:math';

import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';

class Agenda extends StatefulWidget {
  final double cardHeight = 56.0;
  final double cardMargin = 4;
  final ActivitiesOccasionLoaded state;

  const Agenda({Key key, this.state}) : super(key: key);

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
    } else {
      BlocProvider.of<ScrollPositionBloc>(context).add(WrongDaySelected());
    }
    final activities = state.activities;
    final fullDayActivities = state.fullDayActivities;
    return Column(
      children: <Widget>[
        if (fullDayActivities.isNotEmpty)
          FullDayContainer(
            fullDayActivities: fullDayActivities,
            cardHeight: widget.cardHeight,
            cardMargin: widget.cardMargin,
            day: state.day,
          ),
        Expanded(
          child: RefreshIndicator(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: activities.length,
                          itemBuilder: (context, index) => ActivityCard(
                            activityOccasion: activities[index],
                            cardMargin: widget.cardMargin / 2,
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

class FullDayContainer extends StatelessWidget {
  const FullDayContainer(
      {Key key,
      @required this.fullDayActivities,
      @required this.cardHeight,
      @required this.cardMargin,
      @required this.day})
      : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final double cardHeight;
  final DateTime day;
  final double cardMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: fullDayActivities
              .take(2)
              .map<Widget>(
                (fd) => Flexible(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: cardMargin),
                    child: ActivityCard(activityOccasion: fd),
                  ),
                ),
              )
              .followedBy([
            if (fullDayActivities.length >= 3)
              ShowAllFullDayActivitiesButton(
                  fullDayActivities: fullDayActivities,
                  day: day,
                  cardHeight: cardHeight,
                  cardMargin: cardMargin)
          ]).toList(),
        ),
      ),
    );
  }
}

class ShowAllFullDayActivitiesButton extends StatelessWidget {
  const ShowAllFullDayActivitiesButton({
    Key key,
    @required this.fullDayActivities,
    @required this.day,
    @required this.cardHeight,
    @required this.cardMargin,
  }) : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;
  final double cardHeight;
  final double cardMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      child: ActionButton(
        child: Text('+ ${fullDayActivities.length - 2}'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (innerContext) => editActivityMultiBlocProvider(
                context,
                child: AllDayList(
                  pickedDay: day,
                  allDayActivities: fullDayActivities,
                  cardHeight: this.cardHeight,
                  cardMargin: this.cardMargin,
                ),
              ),
              fullscreenDialog: true,
            ),
          );
        },
      ),
    );
  }
}
