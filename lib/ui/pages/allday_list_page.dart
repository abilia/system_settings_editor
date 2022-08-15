import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/occasion/activity_occasion.dart';
import 'package:seagull/models/occasion/event_occasion.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class AllDayList extends StatelessWidget {
  final DateTime day;

  const AllDayList({
    required this.day,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final now = DateTime.now();
        final occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;
        final dayActivities = state.activities
            .expand((activity) => activity.dayActivitiesForDay(day))
            .toList();
        final fullDayActivities = dayActivities
            .where((activityDay) => activityDay.activity.fullDay)
            .map((e) => ActivityOccasion(e.activity, day, occasion))
            .toList();
        fullDayActivities.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));

        return Builder(
          builder: (context) {
            final dayColor = context.select((MemoplannerSettingBloc bloc) =>
                bloc.state.settings.calendar.dayColor);
            return Theme(
              data: weekdayTheme(
                      dayColor: dayColor,
                      languageCode:
                          Localizations.localeOf(context).languageCode,
                      weekday: day.weekday)
                  .theme,
              child: Builder(
                builder: (context) => Scaffold(
                  body: Scrollbar(
                    child: ListView.builder(
                      itemExtent: layout.eventCard.height +
                          layout.eventCard.marginSmall,
                      padding: layout.templates.s1,
                      itemCount: fullDayActivities.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: layout.eventCard.marginSmall,
                        ),
                        child: ActivityCard(
                          activityOccasion: fullDayActivities[index],
                        ),
                      ),
                    ),
                  ),
                  appBar: DayAppBar(day: day),
                  bottomNavigationBar: const BottomNavigation(
                    backNavigationWidget: CloseButton(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
