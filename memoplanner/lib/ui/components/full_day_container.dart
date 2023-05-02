import 'package:collection/collection.dart';
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
    final nightMode = context.watch<NightMode>().state;

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
                  ...fullDayActivities.take(2).mapIndexed<Widget>(
                        (i, fd) => Flexible(
                          child: Padding(
                            padding: i > 0
                                ? EdgeInsets.only(
                                    left: layout.eventCard.marginSmall,
                                  )
                                : EdgeInsets.zero,
                            child: ActivityCard(
                              activityOccasion: fd,
                              useOpacity: nightMode,
                            ),
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
        onPressed: () async {
          final authProviders = copiedAuthProviders(context);

          await Navigator.of(context).push(
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
