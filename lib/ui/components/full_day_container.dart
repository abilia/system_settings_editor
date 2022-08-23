import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
    final calendarSettings =
        context.select<MemoplannerSettingBloc, GeneralCalendarSettings>(
            (bloc) => bloc.state.settings.calendar);
    final dayCalendarType =
        context.select<MemoplannerSettingBloc, DayCalendarType>(
            (bloc) => bloc.state.dayCalendarType);
    final currentHour =
        context.select((ClockBloc bloc) => bloc.state.onlyHours());
    final timePillarState = context.watch<TimepillarCubit>().state;
    bool isTimepillar = dayCalendarType != DayCalendarType.list;
    bool nightMode = (!isTimepillar || timePillarState.showNightCalendar) &&
        currentHour.isAtSameDay(day) &&
        context.read<DayPartCubit>().state.isNight;

    return Theme(
      data: weekdayTheme(
        dayColor: nightMode ? DayColor.noColors : calendarSettings.dayColor,
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
                children: fullDayActivities
                    .take(2)
                    .map<Widget>(
                      (fd) => Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: layout.eventCard.marginSmall,
                          ),
                          child: ActivityCard(activityOccasion: fd),
                        ),
                      ),
                    )
                    .followedBy([
                  if (fullDayActivities.length >= 3)
                    FullDayActivitiesButton(
                      numberOffullDayActivities: fullDayActivities.length,
                      day: day,
                    )
                ]).toList(),
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
    required this.numberOffullDayActivities,
    required this.day,
    Key? key,
  }) : super(key: key);

  final int numberOffullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.commonCalendar.fullDayButtonPadding,
      child: IconActionButton(
        onPressed: () {
          final authProviders = copiedAuthProviders(context);

          Navigator.of(context).push(
            PageRouteBuilder(
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
              settings: RouteSettings(name: 'FullDayListPage $day'),
            ),
          );
        },
        child: Text('+ ${numberOffullDayActivities - 2}'),
      ),
    );
  }
}
