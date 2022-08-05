import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';

class MonthListPreview extends StatelessWidget {
  final List<DayTheme> dayThemes;

  const MonthListPreview({
    required this.dayThemes,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, dayPickerState) {
      return BlocBuilder<MonthCalendarCubit, MonthCalendarState>(
          buildWhen: (previous, current) =>
              previous.firstDay != current.firstDay ||
              previous.occasion != current.occasion,
          builder: (context, monthCalendarState) {
            final showPreview =
                monthCalendarState.firstDay.month == dayPickerState.day.month &&
                    monthCalendarState.firstDay.year == dayPickerState.day.year;

            if (!showPreview) {
              return Padding(
                padding: layout.monthCalendar.monthPreview.noSelectedDayPadding,
                child: Text(
                  Translator.of(context).translate.selectADayToViewDetails,
                  style: abiliaTextTheme.bodyText1,
                ),
              );
            } else {
              final dayTheme = dayThemes[dayPickerState.day.weekday - 1];

              return Padding(
                padding:
                    layout.monthCalendar.monthPreview.monthListPreviewPadding,
                child: Column(
                  children: [
                    AnimatedTheme(
                      data: dayTheme.theme,
                      child: MonthDayPreviewHeading(
                        day: dayPickerState.day,
                        isLight: dayTheme.isLight,
                        occasion: dayPickerState.occasion,
                      ),
                    ),
                    const Expanded(child: MonthPreview()),
                  ],
                ),
              );
            }
          });
    });
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
        decoration: const BoxDecoration(color: AbiliaColors.white),
        child: EventList(
          topPadding: layout.monthCalendar.monthPreview.activityListTopPadding,
          bottomPadding:
              layout.monthCalendar.monthPreview.activityListBottomPadding,
        ),
      ),
    );
  }
}

class MonthDayPreviewHeading extends StatelessWidget {
  const MonthDayPreviewHeading({
    required this.day,
    required this.isLight,
    required this.occasion,
    Key? key,
  }) : super(key: key);

  final DateTime day;
  final bool isLight;
  final Occasion occasion;

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
            .format(day);
    final previewLayout = layout.monthCalendar.monthPreview;
    return Tts.data(
      data: dateText,
      child: GestureDetector(
        onTap: () => DefaultTabController.of(context)?.animateTo(0),
        child: Container(
          padding: previewLayout.headingPadding,
          height: previewLayout.headingHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: radius),
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
          child: BlocBuilder<DayEventsCubit, EventsState>(
            builder: (context, eventState) {
              if (eventState is EventsLoading) return const SizedBox.shrink();
              final fullDayActivities = eventState.fullDayActivities.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: (fullDayActivities > 0)
                          ? CrossOver(
                              style: CrossOverStyle.darkSecondary,
                              applyCross: occasion.isPast,
                              padding: previewLayout.crossOverPadding,
                              child: (fullDayActivities > 1)
                                  ? FullDayStack(
                                      key: TestKey
                                          .monthPreviewHeaderFullDayStack,
                                      numberOfActivities: fullDayActivities,
                                      width: previewLayout
                                          .headingFullDayActivityWidth,
                                      height: previewLayout
                                          .headingFullDayActivityHeight,
                                      goToActivitiesListOnTap: true,
                                      day: eventState.day,
                                    )
                                  : MonthActivityContent(
                                      key: TestKey.monthPreviewHeaderActivity,
                                      activityDay:
                                          eventState.fullDayActivities.first,
                                      isPast: eventState
                                          .fullDayActivities.first.isPast,
                                      width: previewLayout
                                          .headingFullDayActivityWidth,
                                      height: previewLayout
                                          .headingFullDayActivityHeight,
                                      goToActivityOnTap: true,
                                    ),
                            )
                          : null,
                    ),
                  ),
                  CrossOver(
                    style: isLight
                        ? CrossOverStyle.lightDefault
                        : CrossOverStyle.darkDefault,
                    applyCross: occasion.isPast,
                    fallbackHeight: previewLayout.dateTextCrossOverSize.height,
                    fallbackWidth: previewLayout.dateTextCrossOverSize.width,
                    child: Center(
                      child: Text(
                        dateText,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
