import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TwoTimepillarCalendar extends StatelessWidget {
  TwoTimepillarCalendar({
    Key? key,
    required this.activityState,
    required this.timepillarState,
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
    required this.memoplannerSettingsState,
    bool? showCategoryLabels,
  })  : showCategoryLabels = showCategoryLabels ?? showCategories,
        super(key: key);

  final ActivitiesOccasionLoaded activityState;
  final TimepillarState timepillarState;
  final bool showCategories,
      displayHourLines,
      displayTimeline,
      showCategoryLabels;
  final DayParts dayParts;
  final MemoplannerSettingsState memoplannerSettingsState;

  final verticalMargin = 24.s;

  @override
  Widget build(BuildContext context) {
    final day = activityState.day;
    final dayTimepillarState = TimepillarState(
      TimepillarInterval(
        start: day.add(memoplannerSettingsState.dayParts.morning),
        end: day.add(memoplannerSettingsState.dayParts.night),
      ),
      0.5,
    );
    final nightTimepillarState = TimepillarState(
      TimepillarInterval(
        start: day.add(memoplannerSettingsState.dayParts.night),
        end: day.nextDay().add(
              memoplannerSettingsState.dayParts.morningStart.milliseconds(),
            ),
        intervalPart: IntervalPart.NIGHT,
      ),
      0.5,
    );
    return LayoutBuilder(
      builder: (context, boxConstraints) {
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
                  child: BlocProvider<TimepillarBloc>(
                    create: (_) =>
                        TimepillarBloc.fixed(state: dayTimepillarState),
                    child: OneTimepillarCalendar(
                      activityState: activityState,
                      timepillarState: dayTimepillarState,
                      dayParts: memoplannerSettingsState.dayParts,
                      displayTimeline: memoplannerSettingsState.displayTimeline,
                      showCategories: memoplannerSettingsState.showCategories,
                      showCategoryLabels: false,
                      scrollToTimeOffset: false,
                      displayHourLines:
                          memoplannerSettingsState.displayHourLines,
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
                      BlocProvider<TimepillarBloc>(
                        create: (_) =>
                            TimepillarBloc.fixed(state: nightTimepillarState),
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
                          ActivitiesOccasionLoaded>(
                        builder: (context, nightState) => OneTimepillarCalendar(
                          activityState: nightState,
                          timepillarState: nightTimepillarState,
                          dayParts: memoplannerSettingsState.dayParts,
                          displayTimeline:
                              memoplannerSettingsState.displayTimeline,
                          showCategories:
                              memoplannerSettingsState.showCategories,
                          showCategoryLabels: false,
                          scrollToTimeOffset: false,
                          displayHourLines:
                              memoplannerSettingsState.displayHourLines,
                          topMargin: verticalMargin,
                          bottomMargin: verticalMargin,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (memoplannerSettingsState.showCategories) ...[
              LeftCategory(maxWidth: categoryLabelWidth),
              RightCategory(maxWidth: categoryLabelWidth),
            ],
          ],
        );
      },
    );
  }
}
