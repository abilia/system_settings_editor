import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class WeekAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WeekAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
    final weekCalendarSettings = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.weekCalendar);
    final time = context.select((ClockBloc bloc) => bloc.state.onlyDays());
    final currentWeekStart =
        context.select((WeekCalendarCubit bloc) => bloc.state.currentWeekStart);
    return CalendarAppBar(
      showClock: weekCalendarSettings.showClock,
      day: time.onlyDays(),
      calendarDayColor: currentWeekStart.isSameWeekAndYear(time.onlyDays())
          ? calendarSettings.dayColor
          : DayColor.noColors,
      rows: AppBarTitleRows.week(
        selectedWeekStart: currentWeekStart,
        selectedDay: time.onlyDays(),
        translator: Translator.of(context).translate,
        settings: weekCalendarSettings,
        langCode: Localizations.localeOf(context).toLanguageTag(),
      ),
      leftAction: weekCalendarSettings.showBrowseButtons
          ? LeftNavButton(
              onPressed: () async =>
                  BlocProvider.of<WeekCalendarCubit>(context).previousWeek(),
            )
          : null,
      clockReplacement: !currentWeekStart.isSameWeekAndYear(time)
          ? GoToCurrentActionButton(
              onPressed: () async {
                context.read<DayPickerBloc>().add(const CurrentDay());
                await context.read<WeekCalendarCubit>().goToCurrentWeek();
              },
            )
          : null,
      rightAction: weekCalendarSettings.showBrowseButtons
          ? RightNavButton(
              onPressed: () async =>
                  BlocProvider.of<WeekCalendarCubit>(context).nextWeek(),
            )
          : null,
      crossedOver: currentWeekStart.nextWeek().isBefore(time),
    );
  }
}
