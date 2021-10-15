import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (old, fresh) =>
          old.runtimeType != fresh.runtimeType ||
          old.calendarCount != fresh.calendarCount ||
          old.displayBottomBar != fresh.displayBottomBar,
      builder: (context, settingsState) => Listener(
        onPointerDown: Config.isMP
            ? context.read<InactivityCubit>().activityDetected
            : null,
        child: DefaultTabController(
          initialIndex: 0,
          length: settingsState.calendarCount,
          child: Scaffold(
            bottomNavigationBar: settingsState is MemoplannerSettingsLoaded &&
                    settingsState.displayBottomBar
                ? const CalendarBottomBar()
                : null,
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const DayCalendar(),
                if (settingsState.displayWeekCalendar) const WeekCalendarTab(),
                if (settingsState.displayMonthCalendar) const MonthCalendarTab()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
