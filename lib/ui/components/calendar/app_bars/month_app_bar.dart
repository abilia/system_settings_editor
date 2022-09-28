import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonthAppBar({Key? key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<MemoplannerSettingBloc>().state.settings;
    return MonthAppBarStepper(
      showYear: settings.monthCalendar.showYear,
      showBrowseButtons: settings.monthCalendar.showBrowseButtons,
      showClock: settings.monthCalendar.showClock,
      dayColor: settings.calendar.dayColor,
      showDay: true,
    );
  }
}

class MonthAppBarStepper extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.monthStepperHeight);

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
          final currentMonth = state.occasion.isCurrent;
          return CalendarAppBar(
            day: now,
            calendarDayColor: currentMonth ? dayColor : DayColor.noColors,
            crossedOver: state.occasion.isPast,
            rows: AppBarTitleRows.month(
              currentTime: currentMonth ? now : state.firstDay,
              langCode: Localizations.localeOf(context).toLanguageTag(),
              showYear: showYear,
              showDay: showDay && currentMonth,
            ),
            leftAction: showBrowseButtons
                ? LeftNavButton(
                    onPressed: () =>
                        context.read<MonthCalendarCubit>().goToPreviousMonth(),
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
                ? RightNavButton(
                    onPressed: () =>
                        context.read<MonthCalendarCubit>().goToNextMonth(),
                  )
                : null,
          );
        },
      ),
    );
  }
}
