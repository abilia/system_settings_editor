import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';

class FullDayContainer extends StatelessWidget {
  const FullDayContainer(
      {Key key, @required this.fullDayActivities, @required this.day})
      : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;

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
                    padding: EdgeInsets.only(right: ActivityCard.cardMargin),
                    child: ActivityCard(activityOccasion: fd),
                  ),
                ),
              )
              .followedBy([
            if (fullDayActivities.length >= 3)
              ShowAllFullDayActivitiesButton(
                fullDayActivities: fullDayActivities,
                day: day,
              )
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
  }) : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      child: ActionButton(
        child: Text('+ ${fullDayActivities.length - 2}'),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: AllDayList(),
              ),
              settings: RouteSettings(name: 'AllDayList $day'),
            ),
          );
        },
      ),
    );
  }
}
