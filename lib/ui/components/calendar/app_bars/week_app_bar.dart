import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WeekAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) =>
          BlocSelector<ClockBloc, DateTime, DateTime>(
        selector: (state) => state.onlyDays(),
        builder: (context, time) =>
            BlocBuilder<WeekCalendarCubit, WeekCalendarState>(
          buildWhen: (previous, current) =>
              previous.currentWeekStart != current.currentWeekStart,
          builder: (context, state) => CalendarAppBar(
            showClock: memoSettingsState.settings.weekCalendar.showClock,
            day: time.onlyDays(),
            calendarDayColor:
                state.currentWeekStart.isSameWeekAndYear(time.onlyDays())
                    ? memoSettingsState.settings.calendar.dayColor
                    : DayColor.noColors,
            rows: AppBarTitleRows.week(
              selectedWeekStart: state.currentWeekStart,
              selectedDay: time.onlyDays(),
              translator: Translator.of(context).translate,
              showWeekNumber:
                  memoSettingsState.settings.weekCalendar.showWeekNumber,
              showYear: memoSettingsState.settings.weekCalendar.showYear,
              langCode: Localizations.localeOf(context).toLanguageTag(),
            ),
            leftAction: memoSettingsState
                    .settings.weekCalendar.showBrowseButtons
                ? LeftNavButton(
                    onPressed: () => BlocProvider.of<WeekCalendarCubit>(context)
                        .previousWeek(),
                  )
                : null,
            clockReplacement: !state.currentWeekStart.isSameWeekAndYear(time)
                ? GoToCurrentActionButton(
                    onPressed: () {
                      context.read<DayPickerBloc>().add(const CurrentDay());
                      context.read<WeekCalendarCubit>().goToCurrentWeek();
                    },
                  )
                : null,
            rightAction: memoSettingsState
                    .settings.weekCalendar.showBrowseButtons
                ? RightNavButton(
                    onPressed: () =>
                        BlocProvider.of<WeekCalendarCubit>(context).nextWeek(),
                  )
                : null,
            crossedOver: state.currentWeekStart.nextWeek().isBefore(time),
          ),
        ),
      ),
    );
  }
}
