import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AllDayList extends StatelessWidget {
  const AllDayList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesOccasionCubit, ActivitiesOccasionState>(
      builder: (context, state) {
        if (state is ActivitiesOccasionLoaded) {
          return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            builder: (context, memoSettingsState) => Theme(
              data: weekdayTheme(
                      dayColor: memoSettingsState.calendarDayColor,
                      languageCode:
                          Localizations.localeOf(context).languageCode,
                      weekday: state.day.weekday)
                  .theme,
              child: Builder(
                builder: (context) => Scaffold(
                  body: Scrollbar(
                    child: ListView.builder(
                      itemExtent: layout.activityCardLayout.cardHeight +
                          layout.activityCardLayout.cardMarginSmall,
                      padding: EdgeInsets.all(12.s),
                      itemCount: state.fullDayActivities.length,
                      itemBuilder: (context, index) => ActivityCard(
                        activityOccasion: state.fullDayActivities[index],
                        bottomPadding: layout.activityCardLayout.cardMarginSmall,
                      ),
                    ),
                  ),
                  appBar: DayAppBar(day: state.day),
                  bottomNavigationBar: const BottomNavigation(
                    backNavigationWidget: CloseButton(),
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
