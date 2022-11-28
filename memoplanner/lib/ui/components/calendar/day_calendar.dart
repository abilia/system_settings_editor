import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayCalendar extends StatelessWidget {
  static const transitionDuration = Duration(milliseconds: 300);

  const DayCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrollPositionCubit>(
      create: (context) => ScrollPositionCubit(
        dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
      ),
      child: Builder(
        builder: (context) {
          final displayAppbar = context.select((MemoplannerSettingsBloc bloc) =>
              bloc.state.dayCalendar.appBar.displayDayCalendarAppBar);

          return Scaffold(
            appBar: displayAppbar ? const DayCalendarAppBar() : null,
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
              if (isAgenda) return CachedAgenda(index: index);
              return CachedTimepillar(index: index);
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
    final settingsInaccessible = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.settingsInaccessible);
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
        if (settingsInaccessible) const HiddenSetting(),
      ],
    );
  }
}

class _GoToNowPlaceholder extends StatelessWidget {
  const _GoToNowPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: DayCalendar.transitionDuration,
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

class CachedAgenda extends StatelessWidget {
  const CachedAgenda({
    required this.index,
    Key? key,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    final dayEventsCubit = context.watch<DayEventsCubit>();
    final inPageTransition = index != dayEventsCubit.state.day.dayIndex;
    final eventsState =
        inPageTransition ? dayEventsCubit.previousState : dayEventsCubit.state;
    return Column(
      children: <Widget>[
        if (eventsState.fullDayActivities.isNotEmpty)
          FullDayContainer(
            fullDayActivities: eventsState.fullDayActivities,
            day: eventsState.day,
          ),
        Expanded(child: Agenda(eventsState: eventsState))
      ],
    );
  }
}

class CachedTimepillar extends StatelessWidget {
  const CachedTimepillar({
    required this.index,
    Key? key,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (contxt) {
          final dayEventsCubit = context.watch<DayEventsCubit>();
          final inPageTransition = index != dayEventsCubit.state.day.dayIndex;
          final eventsState = inPageTransition
              ? dayEventsCubit.previousState
              : dayEventsCubit.state;
          if (eventsState.fullDayActivities.isEmpty) {
            return const SizedBox.shrink();
          }
          return FullDayContainer(
            fullDayActivities: eventsState.fullDayActivities,
            day: eventsState.day,
          );
        }),
        Builder(
          builder: (context) {
            final measuresCubit = context.watch<TimepillarMeasuresCubit>();
            final timepillarCubit = context.watch<TimepillarCubit>();
            final inPageTransition =
                index != timepillarCubit.state.day.dayIndex;
            return Expanded(
              child: inPageTransition
                  ? TimepillarCalendar(
                      timepillarState: timepillarCubit.previousState,
                      timepillarMeasures: measuresCubit.previousState,
                    )
                  : TimepillarCalendar(
                      timepillarState: timepillarCubit.state,
                      timepillarMeasures: measuresCubit.state,
                    ),
            );
          },
        ),
      ],
    );
  }
}