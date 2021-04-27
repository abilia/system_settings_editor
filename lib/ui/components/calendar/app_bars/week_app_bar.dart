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
            showClock: memoSettingsState.weekCaptionShowClock,
            day: selectedDay,
            calendarDayColor: currentWeekStart.isSameWeek(selectedDay)
                ? memoSettingsState.calendarDayColor
                : DayColor.noColors,
            rows: AppBarTitleRows.week(
              compressDay: memoSettingsState.weekCaptionShowBrowseButtons &&
                  memoSettingsState.weekCaptionShowClock,
              selectedWeekStart: currentWeekStart,
              selectedDay: selectedDay,
              translator: Translator.of(context).translate,
              showWeekNumber: memoSettingsState.weekCaptionShowWeekNumber,
              showYear: memoSettingsState.weekCaptionShowYear,
              langCode: Localizations.localeOf(context).toLanguageTag(),
            ),
            leftAction: memoSettingsState.weekCaptionShowBrowseButtons
                ? ActionButton(
                    onPressed: () => BlocProvider.of<WeekCalendarBloc>(context)
                        .add(PreviousWeek()),
                    child: const Icon(AbiliaIcons.return_to_previous_page),
                  )
                : null,
            clockReplacement: !currentWeekStart.isSameWeek(time)
                ? GoToCurrentActionButton(
                    onPressed: () =>
                        context.read<WeekCalendarBloc>().add(GoToCurrentWeek()),
                  )
                : null,
            rightAction: memoSettingsState.weekCaptionShowBrowseButtons
                ? ActionButton(
                    onPressed: () => BlocProvider.of<WeekCalendarBloc>(context)
                        .add(NextWeek()),
                    child: const Icon(AbiliaIcons.go_to_next_page),
                  )
                : null,
            crossedOver: currentWeekStart.nextWeek().isBefore(time),
          );
        },
      ),
    );
  }
}
