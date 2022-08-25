import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class FullDayListPage extends StatelessWidget {
  const FullDayListPage({
    required this.fullDayActivities,
    required this.day,
    Key? key,
  }) : super(key: key);

  final List<ActivityOccasion> fullDayActivities;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final dayColor = context.select(
        (MemoplannerSettingBloc bloc) => bloc.state.settings.calendar.dayColor);
    return Theme(
      data: weekdayTheme(
              dayColor: dayColor,
              languageCode: Localizations.localeOf(context).languageCode,
              weekday: day.weekday)
          .theme,
      child: Scaffold(
        body: Scrollbar(
          child: ListView.builder(
            itemExtent: layout.eventCard.height + layout.eventCard.marginSmall,
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
    );
  }
}