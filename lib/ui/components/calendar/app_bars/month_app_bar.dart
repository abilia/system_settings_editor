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
      builder: (context, settingState) => MonthAppBarStepper(
        showYear: settingState.monthCaptionShowYear,
        showBrowseButtons: settingState.monthCaptionShowBrowseButtons,
        showClock: settingState.monthCaptionShowClock,
        dayColor: settingState.calendarDayColor,
        showDay: true,
      ),
    );
  }
}

class MonthAppBarStepper extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => AbiliaAppBar.size;

  final bool showYear, showDay, showBrowseButtons, showClock;
  final DayColor dayColor;
  const MonthAppBarStepper({
    Key? key,
    this.showYear = true,
    this.showDay = false,
    this.showBrowseButtons = true,
    this.showClock = false,
    this.dayColor = DayColor.noColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarCubit, MonthCalendarState>(
      builder: (context, state) => BlocBuilder<ClockBloc, DateTime>(
        buildWhen: ((previous, current) => previous.day != current.day),
        builder: (context, now) {
          final currentMonth = state.occasion == Occasion.current;
          return CalendarAppBar(
            day: now,
            calendarDayColor: currentMonth ? dayColor : DayColor.noColors,
            rows: AppBarTitleRows.month(
              currentTime: currentMonth ? now : state.firstDay,
              langCode: Localizations.localeOf(context).toLanguageTag(),
              showYear: showYear,
              showDay: showDay && currentMonth,
            ),
            leftAction: showBrowseButtons
                ? IconActionButton(
                    onPressed: () =>
                        context.read<MonthCalendarCubit>().goToPreviousMonth(),
                    child: const Icon(AbiliaIcons.returnToPreviousPage),
                  )
                : null,
            showClock: showClock,
            clockReplacement: !currentMonth
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
          );
        },
      ),
    );
  }
}
