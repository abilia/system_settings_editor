// @dart=2.9

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
      builder: (context, settingState) => MonthAppBarStepper(
        showYear: settingState.monthCaptionShowYear,
        showBrowseButtons: settingState.monthCaptionShowBrowseButtons,
        showClock: settingState.monthCaptionShowClock,
      ),
    );
  }
}

class MonthAppBarStepper extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => CalendarAppBar.size;

  final bool showYear, showBrowseButtons, showClock;
  const MonthAppBarStepper({
    Key key,
    this.showYear = true,
    this.showBrowseButtons = true,
    this.showClock = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarBloc, MonthCalendarState>(
      buildWhen: (previous, current) =>
          previous.firstDay != current.firstDay ||
          previous.occasion != current.occasion,
      builder: (context, state) => CalendarAppBar(
        day: state.firstDay,
        calendarDayColor: DayColor.noColors,
        rows: AppBarTitleRows.month(
          currentTime: state.firstDay,
          langCode: Localizations.localeOf(context).toLanguageTag(),
          showYear: showYear,
        ),
        leftAction: showBrowseButtons
            ? ActionButton(
                onPressed: () =>
                    context.read<MonthCalendarBloc>().add(GoToPreviousMonth()),
                child: const Icon(AbiliaIcons.return_to_previous_page),
              )
            : null,
        showClock: showClock,
        clockReplacement: state.occasion != Occasion.current
            ? GoToCurrentActionButton(
                onPressed: () =>
                    context.read<MonthCalendarBloc>().add(GoToCurrentMonth()),
              )
            : null,
        rightAction: showBrowseButtons
            ? ActionButton(
                onPressed: () =>
                    context.read<MonthCalendarBloc>().add(GoToNextMonth()),
                child: const Icon(AbiliaIcons.go_to_next_page),
              )
            : null,
      ),
    );
  }
}
