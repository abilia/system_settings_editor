import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TwoTimepillarCalendar extends StatelessWidget {
  TwoTimepillarCalendar({
    Key? key,
    required this.eventState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
  }) : super(key: key);

  final EventsOccasionLoaded eventState;

  final bool showCategories, displayHourLines, displayTimeline;

  final DayParts dayParts;

  final verticalMargin = 24.s;

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
    final tpHeight = timePillarHeight(TimepillarState(maxInterval, 1.0)) +
        verticalMargin * 2;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final zoom = boxConstraints.maxHeight / tpHeight;
        final nightTimepillarState = TimepillarState(nightInterval, zoom);
        final dayTimepillarState = TimepillarState(dayInterval, zoom);
        final categoryLabelWidth =
            (boxConstraints.maxWidth - defaultTimePillarWidth) / 2;
        final nightTimepillarHeight =
            timePillarHeight(nightTimepillarState) + verticalMargin * 2;
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
                      timepillarState: dayTimepillarState,
                      dayParts: dayParts,
                      displayTimeline: displayTimeline,
                      showCategories: showCategories,
                      showCategoryLabels: false,
                      scrollToTimeOffset: false,
                      displayHourLines: displayHourLines,
                      topMargin: verticalMargin,
                      bottomMargin: verticalMargin,
                    ),
                  ),
                ),
                SizedBox(width: 4.s),
                Flexible(
                  flex: 135,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<TimepillarCubit>(
                        create: (_) =>
                            TimepillarCubit.fixed(state: nightTimepillarState),
                      ),
                      BlocProvider<NightActivitiesCubit>(
                        create: (context) => NightActivitiesCubit(
                          activitiesBloc: context.read<ActivitiesBloc>(),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(9.s)),
                      ),
                      child: BlocBuilder<NightActivitiesCubit,
                          EventsOccasionLoaded>(
                        builder: (context, nightState) =>
                            BlocBuilder<ClockBloc, DateTime>(
                          builder: (context, now) {
                            return OneTimepillarCalendar(
                              eventState: nightState,
                              timepillarState: nightTimepillarState,
                              dayParts: dayParts,
                              displayTimeline: displayTimeline,
                              showCategories: showCategories,
                              showCategoryLabels: false,
                              scrollToTimeOffset: false,
                              displayHourLines: displayHourLines,
                              topMargin: verticalMargin,
                              bottomMargin: verticalMargin,
                            );
                          },
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
