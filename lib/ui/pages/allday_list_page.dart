import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class AllDayList extends StatelessWidget {
  const AllDayList({
    Key key,
    @required this.pickedDay,
    @required this.allDayActivities,
    @required this.cardHeight,
    @required this.cardMargin,
  }) : super(key: key);

  final DateTime pickedDay;
  final List<ActivityOccasion> allDayActivities;
  final double cardHeight;
  final double cardMargin;

  @override
  Widget build(BuildContext context) {
    final theme = weekDayTheme[pickedDay.weekday].copyWith(
        scaffoldBackgroundColor: weekDayColor[pickedDay.weekday][120]);
    return Theme(
      data: theme,
      child: Scaffold(
        body: Scrollbar(
          child: ListView.builder(
            itemExtent: this.cardHeight + this.cardMargin,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: allDayActivities.length,
            itemBuilder: (context, index) => ActivityCard(
              activityOccasion: allDayActivities[index],
              cardMargin: this.cardMargin / 2,
            ),
          ),
        ),
        appBar: DayAppBar(
          day: pickedDay,
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
}
