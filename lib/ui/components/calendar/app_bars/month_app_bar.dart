import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonthAppBar({Key? key}) : super(key: key);
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
  Size get preferredSize => AbiliaAppBar.size;

  final bool showYear, showBrowseButtons, showClock;
  const MonthAppBarStepper({
    Key? key,
    this.showYear = true,
    this.showBrowseButtons = true,
    this.showClock = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarCubit, MonthCalendarState>(
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
            ? IconActionButton(
                onPressed: () =>
                    context.read<MonthCalendarCubit>().goToPreviousMonth(),
                child: const Icon(AbiliaIcons.returnToPreviousPage),
              )
            : null,
        showClock: showClock,
        clockReplacement: state.occasion != Occasion.current
            ? GoToCurrentActionButton(
                onPressed: () =>
                    context.read<MonthCalendarCubit>().goToCurrentMonth(),
              )
            : null,
        rightAction: showBrowseButtons
            ? IconActionButton(
                onPressed: () =>
                    context.read<MonthCalendarCubit>().goToNextMonth(),
                child: const Icon(AbiliaIcons.goToNextPage),
              )
            : null,
      ),
    );
  }
}
