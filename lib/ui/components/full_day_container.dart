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
    bool isNight = (!isTimepillar || timePillarState.showNightCalendar) &&
        currentHour.isAtSameDay(day) &&
        currentHour.dayPart(calendarSettings.dayParts) == DayPart.night;

    return Theme(
      data: weekdayTheme(
        dayColor: isNight ? DayColor.noColors : calendarSettings.dayColor,
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
                    ShowAllFullDayActivitiesButton(
                      fullDayActivities: fullDayActivities,
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

class ShowAllFullDayActivitiesButton extends StatelessWidget {
  const ShowAllFullDayActivitiesButton({
    required this.fullDayActivities,
    required this.day,
    Key? key,
  }) : super(key: key);

  final List<ActivityDay> fullDayActivities;
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
                  child: AllDayList(
                    day: day,
                  ),
                ),
              ),
              settings: RouteSettings(name: 'AllDayList $day'),
            ),
          );
        },
        child: Text('+ ${fullDayActivities.length - 2}'),
      ),
    );
  }
}
