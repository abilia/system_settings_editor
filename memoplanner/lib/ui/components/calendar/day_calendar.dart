import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayCalendarTab extends CalendarTab {
  static const transitionDuration = Duration(milliseconds: 300);

  const DayCalendarTab({super.key});

  @override
  PreferredSizeWidget get appBar => const DayCalendarAppBar();

  @override
  Widget floatingActionButton(BuildContext context) {
    final displayEyeButton = context
        .select((DayCalendarViewCubit bloc) => bloc.state.displayEyeButton);
    return FloatingActions(displayEyeButton: displayEyeButton);
  }

  @override
  Widget build(BuildContext context) {
    return const Calendars();
  }
}

class Calendars extends StatefulWidget {
  const Calendars({
    super.key,
  });

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<DayPickerBloc>().add(const CurrentDay());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAgenda = context.select((DayCalendarViewCubit bloc) =>
        bloc.state.calendarType == DayCalendarType.list);
    return BlocListener<DayPickerBloc, DayPickerState>(
      listenWhen: (previous, current) => previous.index != current.index,
      listener: (context, state) async => pageController.animateToPage(
        state.index,
        duration: animationDuration,
        curve: animationCurve,
      ),
      child: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            itemBuilder: (context, index) {
              final dayEventsCubit = context.watch<DayEventsCubit>();
              final inPageTransition =
                  index != dayEventsCubit.state.day.dayIndex;
              final eventsState = inPageTransition
                  ? dayEventsCubit.previousState
                  : dayEventsCubit.state;
              return Column(
                children: [
                  if (eventsState.fullDayActivities.isNotEmpty)
                    FullDayContainer(
                      fullDayActivities: eventsState.fullDayActivities,
                      day: eventsState.day,
                    ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: isAgenda
                          ? Agenda(eventsState: eventsState)
                          : CachedTimepillar(
                              inPageTransition: inPageTransition,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          Column(
            children: [
              // Ensures position of categories and hidden settings
              BlocSelector<DayEventsCubit, EventsState, bool>(
                selector: (state) => state.fullDayActivities.isNotEmpty,
                builder: (context, hasFullDay) => AnimatedSize(
                  duration: animationDuration,
                  curve: animationCurve,
                  child: SafeArea(
                    child: SizedBox(
                      height: hasFullDay
                          ? layout.commonCalendar.fullDayPadding.vertical +
                              layout.eventCard.height
                          : null,
                    ),
                  ),
                ),
              ),
              const CategoriesAndHiddenSettings(),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoriesAndHiddenSettings extends StatelessWidget {
  const CategoriesAndHiddenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final showCategories = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories.show);

    return Column(
      children: [
        if (showCategories)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: LeftCategory()),
              Expanded(child: RightCategory()),
            ],
          ),
        const HiddenSetting(),
      ],
    );
  }
}

class CachedTimepillar extends StatelessWidget {
  final bool inPageTransition;

  const CachedTimepillar({
    required this.inPageTransition,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(
          builder: (context) {
            final measuresCubit = context.watch<TimepillarMeasuresCubit>();
            final timepillarCubit = context.watch<TimepillarCubit>();
            final timepillarState = inPageTransition
                ? timepillarCubit.previousState
                : timepillarCubit.state;
            final timepillarMeasures = inPageTransition
                ? measuresCubit.previousState
                : measuresCubit.state;
            return Expanded(
              child: TimepillarCalendar(
                timepillarState: timepillarState,
                timepillarMeasures: timepillarMeasures,
              ),
            );
          },
        ),
      ],
    );
  }
}
