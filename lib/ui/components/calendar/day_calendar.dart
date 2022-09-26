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
            bloc.state.settings.appBar.displayDayCalendarAppBar);

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
  final animationDuration = const Duration(milliseconds: 500);
  final animationCurve = Curves.easeOutQuad;

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
        pageController.animateToPage(
          state.index,
          duration: animationDuration,
          curve: animationCurve,
        );
      },
      child: LayoutBuilder(builder: (context, boxConstraints) {
        final categoryLabelWidth =
            (boxConstraints.maxWidth - layout.timepillar.width) / 2;
        final showCategories = context.select((MemoplannerSettingBloc bloc) =>
            bloc.state.settings.calendar.categories.show);
        final settingsInaccessible = context.select(
            (MemoplannerSettingBloc bloc) => bloc.state.settingsInaccessible);
        final dayEventsCubit = context.watch<DayEventsCubit>();

        return Stack(
          children: [
            PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, index) {
                return Builder(
                  builder: (context) {
                    final isAgenda = context.select(
                        (MemoplannerSettingBloc b) =>
                            b.state.dayCalendarType == DayCalendarType.list);
                    final timepillarCubit =
                        isAgenda ? null : context.watch<TimepillarCubit>();
                    final timepillarMeasuresCubit = isAgenda
                        ? null
                        : context.watch<TimepillarMeasuresCubit>();
                    final timepillarData = TimepillarData.nullable(
                      timepillarCubit?.state,
                      timepillarMeasuresCubit?.state,
                    );

                    if (dayEventsCubit.state is EventsLoading) {
                      return const SizedBox.shrink();
                    }

                    if (index == dayEventsCubit.state.day.dayIndex) {
                      return DayCalendarPage(
                        eventsState: dayEventsCubit.state,
                        timepillarData: timepillarData,
                      );
                    }

                    final previousEventsState = dayEventsCubit.previousState;
                    final previousTimepillarState =
                        timepillarCubit?.previousState;
                    final previousTimepillarMeasures =
                        timepillarMeasuresCubit?.previousState;
                    final previousTimepillarData = TimepillarData.nullable(
                      previousTimepillarState,
                      previousTimepillarMeasures,
                    );

                    if (previousEventsState != null) {
                      return DayCalendarPage(
                        eventsState: previousEventsState,
                        timepillarData: previousTimepillarData,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
            Column(
              children: [
                //Ensures position of category and now buttons are correct
                AnimatedSize(
                  duration: animationDuration,
                  curve: animationCurve,
                  child: Visibility(
                    visible: false,
                    maintainSize:
                        dayEventsCubit.state.fullDayActivities.isNotEmpty,
                    maintainAnimation: true,
                    maintainState: true,
                    child: FullDayContainer(
                      fullDayActivities: dayEventsCubit.state.fullDayActivities,
                      day: dayEventsCubit.state.day,
                    ),
                  ),
                ),
                Stack(
                  children: [
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class DayCalendarPage extends StatelessWidget {
  const DayCalendarPage({
    required this.eventsState,
    this.timepillarData,
    Key? key,
  }) : super(key: key);

  final EventsState eventsState;
  final TimepillarData? timepillarData;

  @override
  Widget build(BuildContext context) {
    final tpData = timepillarData;
    return Column(
      children: <Widget>[
        if (eventsState.fullDayActivities.isNotEmpty)
          FullDayContainer(
            key: TestKey.fullDayContainer,
            fullDayActivities: eventsState.fullDayActivities,
            day: eventsState.day,
          ),
        Expanded(
          child: Stack(
            children: [
              if (tpData != null)
                TimepillarCalendar(
                  timepillarState: tpData.timepillarState,
                  timepillarMeasures: tpData.timepillarMeasures,
                )
              else
                Agenda(eventsState: eventsState),
            ],
          ),
        ),
      ],
    );
  }
}

class TimepillarData {
  const TimepillarData(
    this.timepillarState,
    this.timepillarMeasures,
  );

  final TimepillarState timepillarState;
  final TimepillarMeasures timepillarMeasures;

  static TimepillarData? nullable(
    TimepillarState? timepillarState,
    TimepillarMeasures? timepillarMeasures,
  ) {
    if (timepillarState != null && timepillarMeasures != null) {
      return TimepillarData(
        timepillarState,
        timepillarMeasures,
      );
    }
    return null;
  }
}
