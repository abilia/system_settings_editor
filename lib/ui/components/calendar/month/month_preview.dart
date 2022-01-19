import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';

class MonthListPreview extends StatelessWidget {
  final List<DayTheme> dayThemes;

  const MonthListPreview({
    Key? key,
    required this.dayThemes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.monthCalendar.monthPreview.monthListPreviewPadding,
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
        horizontal: layout.monthCalendar.monthPreview.monthPreviewBorderWidth,
      ),
      decoration: const BoxDecoration(color: AbiliaColors.transparentBlack30),
      child: Container(
        decoration: const BoxDecoration(color: AbiliaColors.white110),
        child: BlocBuilder<ActivitiesOccasionCubit, ActivitiesOccasionState>(
          builder: (context, activityState) =>
              activityState is ActivitiesOccasionLoaded
                  ? ActivityList(
                      state: activityState,
                      topPadding: layout
                          .monthCalendar.monthPreview.activityListTopPadding,
                      bottomPadding: layout
                          .monthCalendar.monthPreview.activityListBottomPadding,
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
        padding: layout.monthCalendar.monthPreview.headingPadding,
        height: layout.monthCalendar.monthPreview.headingHeight,
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
                    key: TestKey.monthPreviewHeaderFullDayStack,
                    numberOfActivities: fullDayActivies,
                    width: layout
                        .monthCalendar.monthPreview.headingFullDayActivityWidth,
                    height: layout.monthCalendar.monthPreview
                        .headingFullDayActivityHeight,
                  )
                else if (fullDayActivies > 0)
                  MonthActivityContent(
                    key: TestKey.monthPreviewHeaderActivity,
                    activityDay: activityState.fullDayActivities.first,
                    width: layout
                        .monthCalendar.monthPreview.headingFullDayActivityWidth,
                    height: layout.monthCalendar.monthPreview
                        .headingFullDayActivityHeight,
                  ),
                Text(text, style: Theme.of(context).textTheme.subtitle1),
                SecondaryActionButton(
                  onPressed: () =>
                      DefaultTabController.of(context)?.animateTo(0),
                  style: isLight
                      ? secondaryActionButtonStyleLight
                      : secondaryActionButtonStyleDark,
                  child: Icon(
                    AbiliaIcons.navigationNext,
                    size:
                        layout.monthCalendar.monthPreview.headingButtonIconSize,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
