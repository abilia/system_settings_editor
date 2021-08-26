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
          BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, daypickerState) => BlocBuilder<ClockBloc, DateTime>(
          builder: (context, time) =>
              BlocBuilder<WeekCalendarBloc, WeekCalendarState>(
            buildWhen: (previous, current) =>
                previous.currentWeekStart != current.currentWeekStart,
            builder: (context, state) => CalendarAppBar(
              showClock: memoSettingsState.weekCaptionShowClock,
              day: daypickerState.day,
              calendarDayColor:
                  state.currentWeekStart.isSameWeek(daypickerState.day)
                      ? memoSettingsState.calendarDayColor
                      : DayColor.noColors,
              rows: AppBarTitleRows.week(
                selectedWeekStart: state.currentWeekStart,
                selectedDay: daypickerState.day,
                translator: Translator.of(context).translate,
                showWeekNumber: memoSettingsState.weekCaptionShowWeekNumber,
                showYear: memoSettingsState.weekCaptionShowYear,
                langCode: Localizations.localeOf(context).toLanguageTag(),
              ),
              leftAction: memoSettingsState.weekCaptionShowBrowseButtons
                  ? ActionButton(
                      onPressed: () =>
                          BlocProvider.of<WeekCalendarBloc>(context)
                              .add(PreviousWeek()),
                      child: const Icon(AbiliaIcons.return_to_previous_page),
                    )
                  : null,
              clockReplacement: !state.currentWeekStart.isSameWeek(time)
                  ? GoToCurrentActionButton(
                      onPressed: () {
                        context.read<DayPickerBloc>().add(CurrentDay());
                        context.read<WeekCalendarBloc>().add(GoToCurrentWeek());
                      },
                    )
                  : null,
              rightAction: memoSettingsState.weekCaptionShowBrowseButtons
                  ? ActionButton(
                      onPressed: () =>
                          BlocProvider.of<WeekCalendarBloc>(context)
                              .add(NextWeek()),
                      child: const Icon(AbiliaIcons.go_to_next_page),
                    )
                  : null,
              crossedOver: state.currentWeekStart.nextWeek().isBefore(time),
            ),
          ),
        ),
      ),
    );
  }
}
