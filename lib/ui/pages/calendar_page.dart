import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/memoplanner_settings_enums.dart';
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
            ? (_) => context.read<InactivityCubit>().activityDetected()
            : null,
        child: DefaultTabController(
          length: settingsState.calendarCount,
          child: BlocListener<CalendarViewCubit, CalendarViewState>(
            listener: (context, state) =>
                DefaultTabController.of(context)?.animateTo(
              _resolveStartIndex(
                  state.calendarTab,
                  settingsState.displayWeekCalendar,
                  settingsState.displayMonthCalendar,
                  settingsState.displayMenu),
            ),
            child: Scaffold(
              bottomNavigationBar: settingsState is MemoplannerSettingsLoaded &&
                      settingsState.displayBottomBar
                  ? const CalendarBottomBar()
                  : null,
              body: TabBarView(
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

  int _resolveStartIndex(StartView startTab, bool displayWeekCalendar,
      bool displayMonthCalendar, bool displayMenu) {
    switch (startTab) {
      case StartView.dayCalendar:
        return 0;
      case StartView.weekCalendar:
        if (displayWeekCalendar) return 1;
        break;
      case StartView.monthCalendar:
        if (displayMonthCalendar) {
          return displayWeekCalendar ? 2 : 1;
        }
        break;
      case StartView.menu:
        if (displayMenu) {
          return displayWeekCalendar && displayMonthCalendar
              ? 3
              : displayWeekCalendar || displayMonthCalendar
                  ? 2
                  : 1;
        }
        break;
      default:
    }
    return 0;
  }
}
