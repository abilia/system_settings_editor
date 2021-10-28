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
      padding: EdgeInsets.only(left: 8.s, top: 12.s, right: 8.s),
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
      padding: EdgeInsets.only(left: 1.s, right: 1.s),
      decoration: const BoxDecoration(color: AbiliaColors.transparentBlack30),
      child: Container(
        decoration: const BoxDecoration(color: AbiliaColors.white110),
        child: BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
          builder: (context, activityState) =>
              activityState is ActivitiesOccasionLoaded
                  ? ActivityList(
                      state: activityState,
                      topPadding: 12.s,
                      bottomPadding: 64.s,
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
        padding: EdgeInsets.symmetric(horizontal: 12.s),
        height: 48.s,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: radius),
          color: Theme.of(context).appBarTheme.backgroundColor,
        ),
        child: BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
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
                    width: 34.s,
                    height: 32.s,
                  )
                else if (fullDayActivies > 0)
                  MonthActivityContent(
                    activityDay: activityState.fullDayActivities.first,
                    width: 38.s,
                    height: 36.s,
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
            padding: EdgeInsets.all(4.s),
            child: DefaultTextStyle(
              style: dayTheme.theme.textTheme.subtitle2!
                  .copyWith(color: dayTheme.monthSurfaceColor),
              child: Stack(
                children: [
                  Center(child: Text('${day.day.day}')),
                  if (day.hasActivities)
                    Align(
                      alignment: Alignment.topRight,
                      child: ColorDot(
                        color: dayTheme.monthSurfaceColor,
                      ),
                    ),
                  if (day.isPast)
                    Padding(
                      padding: EdgeInsets.all(8.s),
                      child: const CrossOver(),
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
