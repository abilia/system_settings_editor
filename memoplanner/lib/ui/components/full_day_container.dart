import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FullDayContainer extends StatelessWidget {
  const FullDayContainer({
    required this.fullDayActivities,
    required this.day,
    Key? key,
  }) : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final dayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    final dayCalendarType = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.viewOptions.calendarType);
    final currentHour =
        context.select((ClockBloc bloc) => bloc.state.onlyHours());
    final timePillarState = context.watch<TimepillarCubit>().state;
    final isTimepillar = dayCalendarType != DayCalendarType.list;
    final nightMode = (!isTimepillar || timePillarState.showNightCalendar) &&
        currentHour.isAtSameDay(day) &&
        context.read<DayPartCubit>().state.isNight;

    return Theme(
      data: weekdayTheme(
        dayColor: nightMode ? DayColor.noColors : dayColor,
        languageCode: Localizations.localeOf(context).languageCode,
        weekday: day.weekday,
      ).theme,
      child: Builder(
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
          child: Padding(
            padding: layout.commonCalendar.fullDayPadding,
            child: SafeArea(
              child: Row(
                children: [
                  ...fullDayActivities.take(2).map<Widget>(
                        (fd) => Flexible(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: layout.eventCard.marginSmall,
                            ),
                            child: ActivityCard(activityOccasion: fd),
                          ),
                        ),
                      ),
                  if (fullDayActivities.length >= 3)
                    FullDayActivitiesButton(
                      numberOfFullDayActivities: fullDayActivities.length,
                      day: day,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullDayActivitiesButton extends StatelessWidget {
  const FullDayActivitiesButton({
    required this.numberOfFullDayActivities,
    required this.day,
    Key? key,
  }) : super(key: key);

  final int numberOfFullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.commonCalendar.fullDayButtonPadding,
      child: IconActionButton(
        onPressed: () {
          final authProviders = copiedAuthProviders(context);

          Navigator.of(context).push(
            ActivityRootPageRouteBuilder(
              pageBuilder: (_, animation, secondaryAnimation) =>
                  MultiBlocProvider(
                providers: authProviders,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: Builder(
                    builder: (context) => FullDayListPage(
                      fullDayActivities: context.select(
                          (DayEventsCubit cubit) =>
                              cubit.state.fullDayActivities),
                      day: day,
                    ),
                  ),
                ),
              ),
              settings: (FullDayListPage).routeSetting(),
            ),
          );
        },
        child: Text('+ ${numberOfFullDayActivities - 2}'),
      ),
    );
  }
}
