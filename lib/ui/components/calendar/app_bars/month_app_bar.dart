import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonthAppBar({Key key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.monthCaptionShowYear != current.monthCaptionShowYear ||
          previous.monthCaptionShowBrowseButtons !=
              current.monthCaptionShowBrowseButtons ||
          previous.monthCaptionShowClock != current.monthCaptionShowClock,
      builder: (context, settingState) =>
          BlocBuilder<MonthCalendarBloc, MonthCalendarState>(
        builder: (context, state) => CalendarAppBar(
          day: state.firstDay,
          calendarDayColor: DayColor.noColors,
          rows: AppBarTitleRows.month(
            currentTime: state.firstDay,
            langCode: Localizations.localeOf(context).toLanguageTag(),
            showYear: settingState.monthCaptionShowYear,
          ),
          leftAction: settingState.monthCaptionShowBrowseButtons
              ? ActionButton(
                  onPressed: () => context
                      .read<MonthCalendarBloc>()
                      .add(GoToPreviousMonth()),
                  child: const Icon(AbiliaIcons.return_to_previous_page),
                )
              : null,
          showClock: settingState.monthCaptionShowClock,
          clockReplacement: state.occasion == Occasion.current
              ? null
              : GoToCurrentActionButton(
                  onPressed: () =>
                      context.read<MonthCalendarBloc>().add(GoToCurrentMonth()),
                ),
          rightAction: settingState.monthCaptionShowBrowseButtons
              ? ActionButton(
                  onPressed: () =>
                      context.read<MonthCalendarBloc>().add(GoToNextMonth()),
                  child: const Icon(AbiliaIcons.go_to_next_page),
                )
              : null,
        ),
      ),
    );
  }
}
