import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AllDayList extends StatelessWidget {
  const AllDayList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
        builder: (context, state) {
      if (state is ActivitiesOccasionLoaded) {
        return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            builder: (context, memoSettingsState) {
          return Theme(
            data: weekdayTheme(
                    dayColor: memoSettingsState.calendarDayColor,
                    languageCode: Localizations.localeOf(context).languageCode,
                    weekday: state.day.weekday)
                .withScaffoldBackgroundColor,
            child: Scaffold(
              body: Scrollbar(
                child: ListView.builder(
                  itemExtent:
                      ActivityCard.cardHeight + ActivityCard.cardMarginSmall,
                  padding: const EdgeInsets.all(12),
                  itemCount: state.fullDayActivities.length,
                  itemBuilder: (context, index) => ActivityCard(
                    activityOccasion: state.fullDayActivities[index],
                    bottomPadding: ActivityCard.cardMarginSmall,
                  ),
                ),
              ),
              appBar: DayAppBar(
                day: state.day,
              ),
              bottomNavigationBar: BottomNavigation(
                backNavigationWidget: GreyButton(
                  icon: AbiliaIcons.close_program,
                  text: Translator.of(context).translate.close,
                  onPressed: Navigator.of(context).maybePop,
                ),
              ),
            ),
          );
        });
      }
      return Center(child: CircularProgressIndicator());
    });
  }
}
