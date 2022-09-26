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
                  current is ReturnToTodayThresholdReached,
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
    final displayDayCalendarAppBar = context.select(
        (MemoplannerSettingBloc bloc) =>
            bloc.state.settings.dayCalendar.appBar.displayDayCalendarAppBar);

    return Scaffold(
      appBar: displayDayCalendarAppBar ? const DayCalendarAppBar() : null,
      floatingActionButton: const FloatingActions(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: const Calendars(),
    );
  }
}

class Calendars extends StatefulWidget {
  const Calendars({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _CalendarsState();
}

class _CalendarsState extends State<Calendars> with WidgetsBindingObserver {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController(
      initialPage: context.read<DayPickerBloc>().state.index,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            builder: (context, eventState) {
              if (eventState.day.dayIndex != index) {
                return const SizedBox.shrink();
              }

              return Column(
                children: <Widget>[
                  if (eventState.fullDayActivities.isNotEmpty)
                    FullDayContainer(
                      fullDayActivities: eventState.fullDayActivities,
                      day: eventState.day,
                    ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        final categoryLabelWidth = (boxConstraints.maxWidth -
                                layout.timepillar.width) /
                            2;
                        final dayCalendarType = context.select(
                            (MemoplannerSettingBloc bloc) => bloc.state.settings
                                .dayCalendar.viewOptions.calendarType);
                        final showCategories = context.select(
                            (MemoplannerSettingBloc bloc) =>
                                bloc.state.settings.calendar.categories.show);
                        final settingsInaccessible = context.select(
                            (MemoplannerSettingBloc bloc) =>
                                bloc.state.settingsInaccessible);

                        return Stack(
                          children: [
                            if (dayCalendarType == DayCalendarType.list)
                              Agenda(eventState: eventState)
                            else
                              const TimepillarCalendar(),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: layout.commonCalendar.goToNowButtonTop,
                                ),
                                child: const GoToNowButton(),
                              ),
                            ),
                            Column(
                              children: [
                                if (showCategories)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      LeftCategory(
                                        maxWidth: categoryLabelWidth,
                                      ),
                                      RightCategory(
                                        maxWidth: categoryLabelWidth,
                                      ),
                                    ],
                                  ),
                                if (settingsInaccessible) const HiddenSetting(),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
