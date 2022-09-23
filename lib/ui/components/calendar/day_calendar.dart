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
      listenWhen: (previous, current) => previous.index != current.index,
      listener: (context, state) {
        pageController.animateToPage(
          state.index,
          duration: animationDuration,
          curve: animationCurve,
        );
      },
      child: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            itemBuilder: (context, index) => CachedDayCalendar(index: index),
          ),
          Column(
            children: [
              //Ensures position of category and now buttons are correct
              BlocBuilder<DayEventsCubit, EventsState>(
                builder: (context, state) => AnimatedSize(
                  duration: animationDuration,
                  curve: animationCurve,
                  child: Visibility(
                    visible: false,
                    maintainSize: state.fullDayActivities.isNotEmpty,
                    maintainAnimation: true,
                    maintainState: true,
                    child: FullDayContainer(
                      fullDayActivities: state.fullDayActivities,
                      day: state.day,
                    ),
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
                  const CategoriesAndHiddenSettings(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoriesAndHiddenSettings extends StatelessWidget {
  const CategoriesAndHiddenSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsInaccessible = context.select(
        (MemoplannerSettingBloc bloc) => bloc.state.settingsInaccessible);
    final showCategories = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.calendar.categories.show);

    return Column(
      children: [
        if (showCategories)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              LeftCategory(),
              RightCategory(),
            ],
          ),
        if (settingsInaccessible) const HiddenSetting(),
      ],
    );
  }
}

class CachedDayCalendar extends StatelessWidget {
  const CachedDayCalendar({
    required this.index,
    Key? key,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    final isAgenda = context.select((MemoplannerSettingBloc b) =>
        b.state.settings.dayCalendar.viewOptions.calendarType ==
        DayCalendarType.list);
    final timepillarCubit = isAgenda ? null : context.watch<TimepillarCubit>();
    final timepillarMeasuresCubit =
        isAgenda ? null : context.watch<TimepillarMeasuresCubit>();
    final dayEventsCubit = context.read<DayEventsCubit>();

    if (index == dayEventsCubit.state.day.dayIndex) {
      return DayCalendarContent(
        eventsState: dayEventsCubit.state,
        timepillarData: TimepillarData.nullable(
          timepillarCubit?.state,
          timepillarMeasuresCubit?.state,
        ),
      );
    }

    final previousEventsState = dayEventsCubit.previousState;
    if (previousEventsState != null) {
      return DayCalendarContent(
        eventsState: previousEventsState,
        timepillarData: TimepillarData.nullable(
          timepillarCubit?.previousState,
          timepillarMeasuresCubit?.previousState,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class DayCalendarContent extends StatelessWidget {
  const DayCalendarContent({
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
          child: tpData != null
              ? TimepillarCalendar(
                  timepillarState: tpData.timepillarState,
                  timepillarMeasures: tpData.timepillarMeasures,
                )
              : Agenda(eventsState: eventsState),
        )
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
