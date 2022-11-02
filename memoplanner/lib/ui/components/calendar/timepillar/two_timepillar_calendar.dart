import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TwoTimepillarCalendar extends StatelessWidget {
  const TwoTimepillarCalendar({
    required this.showCategories,
    required this.displayHourLines,
    required this.displayTimeline,
    required this.dayParts,
    required this.timepillarState,
    Key? key,
  }) : super(key: key);

  final bool showCategories, displayHourLines, displayTimeline;
  final DayParts dayParts;
  final TimepillarState timepillarState;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DayPickerBloc, DayPickerState, DateTime>(
      selector: (state) => state.day,
      builder: (context, day) {
        final nightInterval = TimepillarInterval(
          start: day.add(dayParts.night),
          end: day.nextDay().add(dayParts.morning),
          intervalPart: IntervalPart.night,
        );
        final dayInterval = TimepillarInterval(
          start: day.add(dayParts.morning),
          end: day.add(dayParts.night),
        );
        final maxInterval =
            dayInterval.lengthInHours > nightInterval.lengthInHours
                ? dayInterval
                : nightInterval;
        final tpHeight = TimepillarMeasures(maxInterval, 1.0).timePillarHeight +
            layout.timepillar.twoTimePillar.verticalMargin * 2;
        return LayoutBuilder(
          builder: (context, boxConstraints) {
            final zoom = boxConstraints.maxHeight / tpHeight;
            final nightTimepillarMeasures =
                TimepillarMeasures(nightInterval, zoom);
            final dayTimepillarMeasures = TimepillarMeasures(dayInterval, zoom);
            final nightTimepillarHeight =
                nightTimepillarMeasures.timePillarHeight +
                    layout.timepillar.twoTimePillar.verticalMargin * 2;
            return Stack(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 232,
                      child: BlocProvider<TimepillarMeasuresCubit>(
                        create: (_) => TimepillarMeasuresCubit.fixed(
                            state: dayTimepillarMeasures),
                        child: OneTimepillarCalendar(
                          timepillarMeasures: dayTimepillarMeasures,
                          timepillarState: timepillarState,
                          dayParts: dayParts,
                          displayTimeline: displayTimeline,
                          showCategories: showCategories,
                          showCategoryLabels: false,
                          scrollToTimeOffset: false,
                          displayHourLines: displayHourLines,
                          topMargin:
                              layout.timepillar.twoTimePillar.verticalMargin,
                          bottomMargin:
                              layout.timepillar.twoTimePillar.verticalMargin,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 135,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: nightTimepillarHeight,
                        margin: EdgeInsets.symmetric(
                          horizontal:
                              layout.timepillar.twoTimePillar.nightMargin,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              layout.timepillar.twoTimePillar.radius,
                            ),
                          ),
                        ),
                        child: BlocProvider<TimepillarMeasuresCubit>(
                          create: (_) => TimepillarMeasuresCubit.fixed(
                              state: nightTimepillarMeasures),
                          child: OneTimepillarCalendar(
                            timepillarMeasures: nightTimepillarMeasures,
                            timepillarState: timepillarState,
                            dayParts: dayParts,
                            displayTimeline: displayTimeline,
                            showCategories: showCategories,
                            showCategoryLabels: false,
                            scrollToTimeOffset: false,
                            pullToRefresh: false,
                            displayHourLines: displayHourLines,
                            topMargin:
                                layout.timepillar.twoTimePillar.verticalMargin,
                            bottomMargin:
                                layout.timepillar.twoTimePillar.verticalMargin,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
