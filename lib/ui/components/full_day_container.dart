import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';

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
