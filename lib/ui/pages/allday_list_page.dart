import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class AllDayList extends StatelessWidget {
  const AllDayList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
        builder: (context, state) {
      if (state is ActivitiesOccasionLoaded) {
        final theme = weekDayTheme[state.day.weekday].copyWith(
            scaffoldBackgroundColor: weekDayColor[state.day.weekday][120]);
        return Theme(
          data: theme,
          child: Scaffold(
            body: Scrollbar(
              child: ListView.builder(
                itemExtent: ActivityCard.cardHeight + ActivityCard.cardMargin,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: state.fullDayActivities.length,
                itemBuilder: (context, index) => ActivityCard(
                  activityOccasion: state.fullDayActivities[index],
                  margin: ActivityCard.cardMargin / 2,
                ),
              ),
            ),
            appBar: DayAppBar(
              day: state.day,
              leftAction: ActionButton(
                child: Icon(
                  AbiliaIcons.close_program,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        );
      }
      return Text('Loading');
    });
  }
}
