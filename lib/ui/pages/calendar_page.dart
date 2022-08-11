import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: Builder(
        builder: (context) {
          if (context.select((MemoplannerSettingBloc bloc) =>
              bloc.state is MemoplannerSettingsNotLoaded)) {
            return const Scaffold(
                body: Center(child: AbiliaProgressIndicator()));
          }
          final functions = context.select(
              (MemoplannerSettingBloc bloc) => bloc.state.settings.functions);
          final display = functions.display;
          return DefaultTabController(
            length: display.calendarCount,
            initialIndex: functions.startViewIndex,
            child: Scaffold(
              bottomNavigationBar:
                  display.bottomBar ? const CalendarBottomBar() : null,
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
                        if (display.week) const WeekCalendarTab(),
                        if (display.month) const MonthCalendarTab(),
                        if (display.menu) const MenuPage(),
                        const PhotoCalendarPage(),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
