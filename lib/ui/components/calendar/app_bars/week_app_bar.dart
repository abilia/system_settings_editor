import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime currentWeekStart;
  final DateTime selectedDay;

  const WeekAppBar({
    Key key,
    @required this.currentWeekStart,
    @required this.selectedDay,
  }) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, time) {
          return CalendarAppBar(
            day: selectedDay,
            calendarDayColor: currentWeekStart.isSameWeek(selectedDay)
                ? memoSettingsState.calendarDayColor
                : DayColor.noColors,
            rows: AppBarTitleRows.week(
              currentTime: time,
              selectedWeekStart: currentWeekStart,
              selectedDay: selectedDay,
              translator: Translator.of(context).translate,
            ),
            leftAction: ActionButton(
              onPressed: () => BlocProvider.of<WeekCalendarBloc>(context)
                  .add(PreviousWeek()),
              child: const Icon(AbiliaIcons.return_to_previous_page),
            ),
            clockReplacement: !currentWeekStart.isSameWeek(time)
                ? GoToCurrentWeekButton()
                : null,
            rightAction: ActionButton(
              onPressed: () =>
                  BlocProvider.of<WeekCalendarBloc>(context).add(NextWeek()),
              child: const Icon(AbiliaIcons.go_to_next_page),
            ),
            crossedOver: currentWeekStart.nextWeek().isBefore(time),
          );
        },
      ),
    );
  }
}
