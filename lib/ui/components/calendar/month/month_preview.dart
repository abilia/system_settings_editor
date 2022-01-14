import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MonthListPreview extends StatelessWidget {
  final List<DayTheme> dayThemes;

  const MonthListPreview({
    Key? key,
    required this.dayThemes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.monthCalendarLayout.monthPreview.monthListPreviewPadding,
      child: Column(
        children: [
          BlocBuilder<DayPickerBloc, DayPickerState>(
            builder: (context, state) {
              final dayTheme = dayThemes[state.day.weekday - 1];

              return AnimatedTheme(
                data: dayTheme.theme,
                child: MonthDayPreviewHeading(
                  day: state.day,
                  isLight: dayTheme.isLight,
                ),
              );
            },
          ),
          const Expanded(child: MonthPreview()),
        ],
      ),
    );
  }
}

class MonthPreview extends StatelessWidget {
  const MonthPreview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            layout.monthCalendarLayout.monthPreview.monthPreviewBorderWidth,
      ),
      decoration: const BoxDecoration(color: AbiliaColors.transparentBlack30),
      child: Container(
        decoration: const BoxDecoration(color: AbiliaColors.white110),
        child: BlocBuilder<ActivitiesOccasionCubit, ActivitiesOccasionState>(
          builder: (context, activityState) =>
              activityState is ActivitiesOccasionLoaded
                  ? ActivityList(
                      state: activityState,
                      topPadding: layout.monthCalendarLayout.monthPreview
                          .activityListTopPadding,
                      bottomPadding: layout.monthCalendarLayout.monthPreview
                          .activityListBottomPadding,
                    )
                  : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class MonthDayPreviewHeading extends StatelessWidget {
  const MonthDayPreviewHeading({
    Key? key,
    required this.day,
    required this.isLight,
  }) : super(key: key);

  final DateTime day;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final text =
        DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
            .format(day);
    return Tts.data(
      data: text,
      child: Container(
        padding: layout.monthCalendarLayout.monthPreview.headingPadding,
        height: layout.monthCalendarLayout.monthPreview.headingHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: radius),
          color: Theme.of(context).appBarTheme.backgroundColor,
        ),
        child: BlocBuilder<ActivitiesOccasionCubit, ActivitiesOccasionState>(
          buildWhen: (oldState, newState) =>
              (oldState is ActivitiesOccasionLoaded &&
                  newState is ActivitiesOccasionLoaded &&
                  oldState.day != newState.day) ||
              oldState.runtimeType != newState.runtimeType,
          builder: (context, activityState) {
            final fullDayActivies = (activityState as ActivitiesOccasionLoaded)
                .fullDayActivities
                .length;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (fullDayActivies > 1)
                  FullDayStack(
                    numberOfActivities: fullDayActivies,
                    width: layout.monthCalendarLayout.monthPreview
                        .headingFullDayActivityWidth,
                    height: layout.monthCalendarLayout.monthPreview
                        .headingFullDayActivityHeight,
                  )
                else if (fullDayActivies > 0)
                  MonthActivityContent(
                    activityDay: activityState.fullDayActivities.first,
                    width: layout.monthCalendarLayout.monthPreview
                        .headingFullDayActivityWidth,
                    height: layout.monthCalendarLayout.monthPreview
                        .headingFullDayActivityHeight,
                  ),
                Text(text, style: Theme.of(context).textTheme.subtitle1),
                SecondaryActionButton(
                  onPressed: () =>
                      DefaultTabController.of(context)?.animateTo(0),
                  style: isLight
                      ? secondaryActionButtonStyleLight
                      : secondaryActionButtonStyleDark,
                  child: const Icon(AbiliaIcons.navigationNext),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

//TODO: Flytta denna klassen till month_calendar.dart
class MonthDayViewCompact extends StatelessWidget {
  final MonthDay day;
  final DayTheme dayTheme;

  const MonthDayViewCompact(
    this.day, {
    Key? key,
    required this.dayTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = dayTheme.theme.textTheme.subtitle1 ?? subtitle1;
    final textWithCorrectColor = day.isPast
        ? textStyle.copyWith(color: AbiliaColors.black)
        : textStyle.copyWith(
            color: dayTheme.monthSurfaceColor,
          );
    return Tts.data(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(day.day),
      child: GestureDetector(
        onTap: () =>
            BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day.day)),
        child: BlocBuilder<DayPickerBloc, DayPickerState>(
          builder: (context, dayPickerState) => Container(
            foregroundDecoration: day.isCurrent
                ? BoxDecoration(
                    border: currentBorder,
                    borderRadius: MonthDayView.monthDayborderRadius,
                  )
                : dayPickerState.day.isAtSameDay(day.day)
                    ? BoxDecoration(
                        border: selectedActivityBorder,
                        borderRadius: MonthDayView.monthDayborderRadius,
                      )
                    : BoxDecoration(
                        border: transparentBlackBorder,
                        borderRadius: MonthDayView.monthDayborderRadius,
                      ),
            decoration: BoxDecoration(
              color: day.isPast ? dayTheme.monthPastColor : dayTheme.monthColor,
              borderRadius: MonthDayView.monthDayborderRadius,
            ),
            padding:
                layout.monthCalendarLayout.monthPreview.dayViewCompactPadding,
            child: DefaultTextStyle(
              style: textWithCorrectColor,
              child: Stack(
                children: [
                  Center(child: Text('${day.day.day}')),
                  if (day.hasActivities)
                    Align(
                      alignment: Alignment.topRight,
                      child: ColorDot(
                        diameter:
                            layout.monthCalendarLayout.hasActivitiesDotDiameter,
                        color: AbiliaColors.black,
                      ),
                    ),
                  if (day.isPast)
                    Padding(
                      padding: layout.monthCalendarLayout.monthPreview
                          .compactCrossOverPadding,
                      child: const CrossOver(
                        color: AbiliaColors.transparentBlack30,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
