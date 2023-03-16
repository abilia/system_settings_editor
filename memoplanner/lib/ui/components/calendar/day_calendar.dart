import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayCalendarTab extends StatelessWidget {
  static const transitionDuration = Duration(milliseconds: 300);

  const DayCalendarTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = context.select((DayPickerBloc bloc) => bloc.state.day);
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
    final isTimepillar = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.viewOptions.calendarType !=
        DayCalendarType.list);
    final currentMinute = context.watch<ClockBloc>().state;
    final dayPart = context.read<DayPartCubit>().state;
    final showNightCalendar = context.select<TimepillarCubit, bool>(
        (cubit) => cubit.state.showNightCalendar);
    final isNight = (!isTimepillar || showNightCalendar) &&
        currentMinute.isAtSameDay(day) &&
        dayPart.isNight;

    final dayTheme = weekdayTheme(
      dayColor: isNight ? DayColor.noColors : calendarSettings.dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return BlocProvider<ScrollPositionCubit>(
      create: (context) => ScrollPositionCubit(
        dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: dayTheme.theme.appBarTheme.backgroundColor,
            appBar: const DayCalendarAppBar(),
            floatingActionButton: const FloatingActions(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            body: const Calendars(),
          );
        },
      ),
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<DayPickerBloc>().add(const CurrentDay());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAgenda = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.viewOptions.calendarType ==
        DayCalendarType.list);
    return BlocListener<DayPickerBloc, DayPickerState>(
      listenWhen: (previous, current) => previous.index != current.index,
      listener: (context, state) => pageController.animateToPage(
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
                  Builder(
                    builder: (context) {
                      if (eventsState.fullDayActivities.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return FullDayContainer(
                        fullDayActivities: eventsState.fullDayActivities,
                        day: eventsState.day,
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      return Expanded(
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: isAgenda
                              ? Agenda(eventsState: eventsState)
                              : CachedTimepillar(
                                  inPageTransition: inPageTransition,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          Column(
            children: [
              //Ensures position of category and now buttons are correct
              BlocSelector<DayEventsCubit, EventsState, bool>(
                selector: (state) => state.fullDayActivities.isNotEmpty,
                builder: (context, hasFullday) => AnimatedSize(
                  duration: animationDuration,
                  curve: animationCurve,
                  child: SafeArea(
                    child: SizedBox(
                      height: hasFullday
                          ? layout.commonCalendar.fullDayPadding.vertical +
                              layout.eventCard.height
                          : null,
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
    final showCategories = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories.show);

    return Column(
      children: [
        if (showCategories)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(child: LeftCategory()),
              _GoToNowPlaceholder(),
              Expanded(child: RightCategory()),
            ],
          ),
        const HiddenSetting(),
      ],
    );
  }
}

class _GoToNowPlaceholder extends StatelessWidget {
  const _GoToNowPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: DayCalendarTab.transitionDuration,
      child: Builder(builder: (context) {
        final showingNowButton = context.select((ScrollPositionCubit c) =>
            c.state is WrongDay || c.state is OutOfView);

        if (showingNowButton) {
          return Visibility(
            visible: false,
            maintainState: true,
            maintainSize: true,
            maintainAnimation: true,
            child: IconAndTextButton(
              text: Translator.of(context).translate.now,
              icon: AbiliaIcons.reset,
              style: actionIconTextButtonStyleRed,
              padding: EdgeInsets.zero,
            ).pad(
              EdgeInsets.symmetric(horizontal: layout.category.topMargin),
            ),
          );
        }

        return SizedBox(width: layout.timepillar.width);
      }),
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
