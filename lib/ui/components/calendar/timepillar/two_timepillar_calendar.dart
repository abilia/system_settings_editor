import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TwoTimepillarCalendar extends StatelessWidget {
  const TwoTimepillarCalendar({
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

  @override
  Widget build(BuildContext context) {
    final day = activityState.day;
    final dayTimepillarState = TimepillarState(
        TimepillarInterval(
          start: day.add(memoplannerSettingsState.dayParts.morning),
          end: day.add(memoplannerSettingsState.dayParts.night),
        ),
        0.5);
    final nightTimepillarState = TimepillarState(
        TimepillarInterval(
          start: day.add(memoplannerSettingsState.dayParts.night),
          end: day.nextDay().add(
                memoplannerSettingsState.dayParts.morningStart.milliseconds(),
              ),
          intervalPart: IntervalPart.NIGHT,
        ),
        0.5);
    return Row(
      children: [
        Flexible(
          flex: 232,
          child: BlocProvider<TimepillarBloc>.value(
            value: TimepillarBloc.fixed(state: dayTimepillarState),
            child: OneTimepillarCalendar(
              activityState: activityState,
              timepillarState: dayTimepillarState,
              dayParts: memoplannerSettingsState.dayParts,
              displayTimeline: memoplannerSettingsState.displayTimeline,
              showCategories: memoplannerSettingsState.showCategories,
              showCategoryLabels: false,
              displayHourLines: memoplannerSettingsState.displayHourLines,
              topMargin: 20.s,
              bottomMargin: 0.0,
            ),
          ),
        ),
        SizedBox(width: 4.s),
        Flexible(
          flex: 135,
          child: BlocProvider<TimepillarBloc>.value(
            value: TimepillarBloc.fixed(state: nightTimepillarState),
            child: Container(
              clipBehavior: Clip.hardEdge,
              height: 242.s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(9.s),
                ),
              ),
              child: OneTimepillarCalendar(
                activityState: activityState,
                timepillarState: nightTimepillarState,
                dayParts: memoplannerSettingsState.dayParts,
                displayTimeline: memoplannerSettingsState.displayTimeline,
                showCategories: memoplannerSettingsState.showCategories,
                showCategoryLabels: false,
                displayHourLines: memoplannerSettingsState.displayHourLines,
                topMargin: 20.s,
                bottomMargin: 0.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
