import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class FullDayContainer extends StatelessWidget {
  const FullDayContainer({
    Key? key,
    required this.fullDayActivities,
    required this.day,
  }) : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => Theme(
        data: weekdayTheme(
                dayColor: memoSettingsState.calendarDayColor,
                languageCode: Localizations.localeOf(context).languageCode,
                weekday: day.weekday)
            .theme,
        child: Builder(
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.all(12.s),
              child: Row(
                children: fullDayActivities
                    .take(2)
                    .map<Widget>(
                      (fd) => Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: ActivityCard.cardMarginSmall,
                          ),
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
          ),
        ),
      ),
    );
  }
}

class ShowAllFullDayActivitiesButton extends StatelessWidget {
  const ShowAllFullDayActivitiesButton({
    Key? key,
    required this.fullDayActivities,
    required this.day,
  }) : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.s, 4.s, 4.s, 4.s),
      child: ActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, animation, secondaryAnimation) =>
                  CopiedAuthProviders(
                blocContext: context,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: const AllDayList(),
                ),
              ),
              settings: RouteSettings(name: 'AllDayList $day'),
            ),
          );
        },
        child: Text('+ ${fullDayActivities.length - 2}'),
      ),
    );
  }
}
