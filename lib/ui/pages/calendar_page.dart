import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          builder: (context, settingsState) {
        if (settingsState is MemoplannerSettingsNotLoaded) {
          return const Center(child: AbiliaProgressIndicator());
        }
        return DefaultTabController(
          length: settingsState.calendarCount,
          initialIndex: settingsState.startViewIndex,
          child: Scaffold(
            bottomNavigationBar:
                settingsState is! MemoplannerSettingsNotLoaded &&
                        settingsState.displayBottomBar
                    ? const CalendarBottomBar()
                    : null,
            body: BlocSelector<ActivitiesBloc, ActivitiesState, bool>(
              selector: (state) => state is ActivitiesNotLoaded,
              builder: (context, activitiesNotLoaded) {
                if (activitiesNotLoaded) {
                  return Center(
                    child: SizedBox(
                      width: layout.login.logoSize,
                      height: layout.login.logoSize,
                      child: const AbiliaProgressIndicator(),
                    ),
                  );
                }
                return ReturnToHomeScreenListener(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const DayCalendar(),
                      if (settingsState.displayWeekCalendar)
                        const WeekCalendarTab(),
                      if (settingsState.displayMonthCalendar)
                        const MonthCalendarTab(),
                      if (settingsState.displayMenu) const MenuPage(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
