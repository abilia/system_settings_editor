import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DayCalendar extends StatelessWidget {
  const DayCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrollPositionCubit>(
      create: (context) => ScrollPositionCubit(
        dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
        clockBloc: context.read<ClockBloc>(),
        timepillarMeasuresCubit: context.read<TimepillarMeasuresCubit>(),
      ),
      child: Config.isMP
          ? BlocListener<InactivityCubit, InactivityState>(
              listenWhen: (previous, current) =>
                  current is CalendarInactivityThresholdReached,
              listener: (context, state) =>
                  BlocProvider.of<ScrollPositionCubit>(context).goToNow(),
              child: const CalendarScaffold())
          : const CalendarScaffold(),
    );
  }
}

class CalendarScaffold extends StatelessWidget {
  const CalendarScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (old, fresh) =>
          old.settingsInaccessible != fresh.settingsInaccessible ||
          old.showCategories != fresh.showCategories ||
          old.displayDayCalendarAppBar != fresh.displayDayCalendarAppBar,
      builder: (context, settingState) => Scaffold(
        appBar: settingState.displayDayCalendarAppBar
            ? const DayCalendarAppBar()
            : null,
        floatingActionButton: const FloatingActions(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: Stack(
          children: [
            const Calendars(),
            if (settingState.settingsInaccessible)
              HiddenSetting(settingState.showCategories),
          ],
        ),
      ),
    );
  }
}

class Calendars extends StatefulWidget {
  const Calendars({Key? key}) : super(key: key);

  @override
  _CalendarsState createState() => _CalendarsState();
}

class _CalendarsState extends State<Calendars> with WidgetsBindingObserver {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    pageController = PageController(
      initialPage: context.read<DayPickerBloc>().state.index,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<ScrollPositionCubit>().goToNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DayPickerBloc, DayPickerState>(
      listener: (context, state) {
        pageController.animateToPage(state.index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemBuilder: (context, index) {
          return BlocBuilder<DayEventsCubit, EventsState>(
            buildWhen: (oldState, newState) {
              return (oldState is EventsLoaded &&
                      newState is EventsLoaded &&
                      oldState.day == newState.day) ||
                  oldState.runtimeType != newState.runtimeType;
            },
            builder: (context, eventState) {
              if (eventState is EventsLoaded) {
                if (eventState.day.dayIndex != index) return Container();
                return Column(
                  children: <Widget>[
                    if (eventState.fullDayActivities.isNotEmpty)
                      FullDayContainer(
                        fullDayActivities: eventState.fullDayActivities,
                        day: eventState.day,
                      ),
                    Expanded(
                      child: BlocBuilder<MemoplannerSettingBloc,
                          MemoplannerSettingsState>(
                        buildWhen: (previous, current) =>
                            previous.dayCalendarType != current.dayCalendarType,
                        builder: (context, memoState) => Stack(
                          children: [
                            if (memoState.dayCalendarType ==
                                DayCalendarType.list)
                              Agenda(eventState: eventState)
                            else
                              TimepillarCalendar(
                                eventState: eventState,
                                type: memoState.dayCalendarType,
                              ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: layout.commonCalendar.goToNowButtonTop,
                                ),
                                child: const GoToNowButton(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
