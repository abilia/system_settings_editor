import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    final isNotLoaded = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state is MemoplannerSettingsNotLoaded);
    if (isNotLoaded) {
      return const Scaffold(
        body: Center(
          child: AbiliaProgressIndicator(),
        ),
      );
    }
    final functionsSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.functions);
    final displaySettings = functionsSettings.display;
    const emptyPage = EmptyCalendarPage();
    const weekTab = WeekCalendarTab();
    const monthTab = MonthCalendarTab();
    const menuPage = MenuPage();

    final tabs = <CalendarTab>[
      const DayCalendarTab(),
      if (displaySettings.week) weekTab else emptyPage,
      if (displaySettings.month) monthTab else emptyPage,
      if (displaySettings.menu) menuPage else emptyPage,
      if (Config.isMP) const PhotoCalendarPage(),
    ];
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocProvider<ScrollPositionCubit>(
        create: (context) => ScrollPositionCubit(
          dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
        ),
        child: DefaultTabController(
          length: displaySettings.calendarCount,
          initialIndex: functionsSettings.startViewIndex,
          child: Builder(
            builder: (context) {
              final controller = DefaultTabController.of(context)
                ..addListener(() => setState(() {}));
              final index = controller.index;
              return Scaffold(
                backgroundColor: _dayTheme(context).color,
                appBar: tabs[index].appBar,
                floatingActionButton: tabs[index].floatingActionButton(context),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.startFloat,
                bottomNavigationBar: displaySettings.bottomBar
                    ? const CalendarBottomBar()
                    : null,
                body: ReturnToHomeScreenListener(
                  child: TrackableTabBarView(
                    analytics: GetIt.I<SeagullAnalytics>(),
                    children: tabs,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  DayTheme _dayTheme(BuildContext context) {
    final day = context.select((DayPickerBloc bloc) => bloc.state.day);
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
    final isNight = context.watch<NightMode>().state;

    return weekdayTheme(
      dayColor: isNight ? DayColor.noColors : calendarSettings.dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
  }
}

abstract class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  PreferredSizeWidget get appBar;

  Widget floatingActionButton(BuildContext context);
}

class EmptyCalendarPage extends CalendarTab {
  const EmptyCalendarPage({super.key});

  @override
  PreferredSizeWidget get appBar => AppBar();

  @override
  Widget floatingActionButton(BuildContext context) => const SizedBox();

  @override
  Widget build(BuildContext context) {
    _navigateToStartView(context);
    return const SizedBox.shrink();
  }

  void _navigateToStartView(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        final tabController = DefaultTabController.of(context);
        final settings = context.read<MemoplannerSettingsBloc>().state;
        await Future.delayed(DayCalendarTab.transitionDuration);
        final startViewIndex = settings.functions.startViewIndex;
        tabController.index = startViewIndex;
      }
    });
  }
}
