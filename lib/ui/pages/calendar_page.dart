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
        buildWhen: (old, fresh) =>
            old.runtimeType != fresh.runtimeType ||
            old.calendarCount != fresh.calendarCount ||
            old.displayBottomBar != fresh.displayBottomBar,
        builder: (context, settingsState) => DefaultTabController(
          length: settingsState.calendarCount,
          child: Scaffold(
            bottomNavigationBar: settingsState is MemoplannerSettingsLoaded &&
                    settingsState.displayBottomBar
                ? const CalendarBottomBar()
                : null,
            body: HomeScreenInactivityListener(
              settingsState: settingsState,
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
            ),
          ),
        ),
      ),
    );
  }
}
