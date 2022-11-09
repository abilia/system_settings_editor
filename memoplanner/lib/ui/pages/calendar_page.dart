import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

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
              body: Builder(
                builder: (context) {
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
      if (mounted) {
        final tabController = DefaultTabController.of(context);
        final settings = context.read<MemoplannerSettingsBloc>().state;
        await Future.delayed(DayCalendar.transitionDuration);
        final startViewIndex = settings.functions.startViewIndex;
        tabController?.index = startViewIndex;
      }
    });
  }
}
