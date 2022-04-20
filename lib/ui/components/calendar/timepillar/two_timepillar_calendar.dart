import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TwoTimepillarCalendar extends StatelessWidget {
  const TwoTimepillarCalendar({
    Key? key,
    required this.eventState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
  }) : super(key: key);

  final EventsLoaded eventState;

  final bool showCategories, displayHourLines, displayTimeline;

  final DayParts dayParts;

  @override
  Widget build(BuildContext context) {
    final day = eventState.day;
    final nightInterval = TimepillarInterval(
      start: day.add(dayParts.night),
      end: day.nextDay().add(dayParts.morningStart.milliseconds()),
      intervalPart: IntervalPart.night,
    );
    final dayInterval = TimepillarInterval(
      start: day.add(dayParts.morning),
      end: day.add(dayParts.night),
    );
    final maxInterval = dayInterval.lengthInHours > nightInterval.lengthInHours
        ? dayInterval
        : nightInterval;
    final tpHeight =
        TimepillarState(maxInterval, 1.0, const []).timePillarHeight +
            layout.timePillar.twoTimePillar.verticalMargin * 2;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final zoom = boxConstraints.maxHeight / tpHeight;
        final nightTimepillarState =
            TimepillarState(nightInterval, zoom, const []);
        final dayTimepillarState = TimepillarState(dayInterval, zoom, const []);
        final categoryLabelWidth =
            (boxConstraints.maxWidth - layout.timePillar.width) / 2;
        final nightTimepillarHeight = nightTimepillarState.timePillarHeight +
            layout.timePillar.twoTimePillar.verticalMargin * 2;
        return Stack(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 232,
                  child: BlocProvider<TimepillarCubit>(
                    create: (_) =>
                        TimepillarCubit.fixed(state: dayTimepillarState),
                    child: OneTimepillarCalendar(
                      eventState: eventState,
                      timepillarState:
                          TimepillarState(dayInterval, zoom, eventState.events),
                      dayParts: dayParts,
                      displayTimeline: displayTimeline,
                      showCategories: showCategories,
                      showCategoryLabels: false,
                      scrollToTimeOffset: false,
                      displayHourLines: displayHourLines,
                      topMargin: layout.timePillar.twoTimePillar.verticalMargin,
                      bottomMargin:
                          layout.timePillar.twoTimePillar.verticalMargin,
                    ),
                  ),
                ),
                Flexible(
                  flex: 135,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<TimepillarCubit>(
                        create: (_) =>
                            TimepillarCubit.fixed(state: nightTimepillarState),
                      ),
                      BlocProvider<NightEventsCubit>(
                        create: (context) => NightEventsCubit(
                          activitiesBloc: context.read<ActivitiesBloc>(),
                          timerAlarmBloc: context.read<TimerAlarmBloc>(),
                          clockBloc: context.read<ClockBloc>(),
                          dayPickerBloc: context.read<DayPickerBloc>(),
                          memoplannerSettingBloc:
                              context.read<MemoplannerSettingBloc>(),
                        ),
                      ),
                    ],
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      height: nightTimepillarHeight,
                      margin: EdgeInsets.symmetric(
                        horizontal: layout.timePillar.twoTimePillar.nightMargin,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            layout.timePillar.twoTimePillar.radius,
                          ),
                        ),
                      ),
                      child: BlocBuilder<NightEventsCubit, EventsLoaded>(
                        builder: (context, nightState) => OneTimepillarCalendar(
                          eventState: nightState,
                          timepillarState: TimepillarState(
                              nightInterval, zoom, nightState.events),
                          dayParts: dayParts,
                          displayTimeline: displayTimeline,
                          showCategories: showCategories,
                          showCategoryLabels: false,
                          scrollToTimeOffset: false,
                          displayHourLines: displayHourLines,
                          topMargin:
                              layout.timePillar.twoTimePillar.verticalMargin,
                          bottomMargin:
                              layout.timePillar.twoTimePillar.verticalMargin,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showCategories) ...[
              LeftCategory(maxWidth: categoryLabelWidth),
              RightCategory(maxWidth: categoryLabelWidth),
            ],
          ],
        );
      },
    );
  }
}
