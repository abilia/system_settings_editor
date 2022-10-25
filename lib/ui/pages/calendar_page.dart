import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: Builder(
        builder: (context) {
          final isNotLoaded = context.select((MemoplannerSettingsBloc bloc) =>
              bloc.state is MemoplannerSettingsNotLoaded);
          if (isNotLoaded) {
            return const Scaffold(
                body: Center(child: AbiliaProgressIndicator()));
          }
          final functionsSettings = context
              .select((MemoplannerSettingsBloc bloc) => bloc.state.functions);
          final display = functionsSettings.display;
          return DefaultTabController(
            length: display.calendarCount,
            initialIndex: functionsSettings.startViewIndex,
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
                  const emptyPage = EmptyCalendarPage();
                  const weekTab = WeekCalendarTab();
                  const monthTab = MonthCalendarTab();
                  const menuPage = MenuPage();
                  return ReturnToHomeScreenListener(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const DayCalendar(),
                        if (display.week) weekTab else emptyPage,
                        if (display.month) monthTab else emptyPage,
                        if (display.menu) menuPage else emptyPage,
                        if (Config.isMP) const PhotoCalendarPage(),
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

class EmptyCalendarPage extends StatefulWidget {
  const EmptyCalendarPage({Key? key}) : super(key: key);

  @override
  State<EmptyCalendarPage> createState() => _EmptyCalendarPageState();
}

class _EmptyCalendarPageState extends State<EmptyCalendarPage> {
  @override
  void initState() {
    super.initState();
    _navigateToStartView();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _navigateToStartView() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tabController = DefaultTabController.of(context);
      final settings = context.read<MemoplannerSettingsBloc>().state;
      await Future.delayed(DayCalendar.calendarTransitionDuration);
      final startViewIndex = settings.functions.startViewIndex;
      tabController?.index = startViewIndex;
    });
  }
}
