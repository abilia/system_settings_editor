import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AllDayList extends StatelessWidget {
  const AllDayList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayEventsCubit, EventsState>(
      builder: (context, state) {
        if (state is EventsLoaded) {
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
                      itemExtent: layout.eventCard.height +
                          layout.eventCard.marginSmall,
                      padding: layout.templates.s1,
                      itemCount: state.fullDayActivities.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: layout.eventCard.marginSmall,
                        ),
                        child: ActivityCard(
                          activityOccasion: state.fullDayActivities[index],
                        ),
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
