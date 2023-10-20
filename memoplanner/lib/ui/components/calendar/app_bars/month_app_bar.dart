import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class MonthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MonthAppBar({super.key});
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final monthCalendarSettings = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.monthCalendar);
    final dayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    return MonthAppBarStepper(
      showYear: monthCalendarSettings.showYear,
      showBrowseButtons: monthCalendarSettings.showBrowseButtons,
      showClock: monthCalendarSettings.showClock,
      dayColor: dayColor,
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
    super.key,
    this.showYear = true,
    this.showDay = false,
    this.showBrowseButtons = true,
    this.showClock = false,
    this.dayColor = DayColor.noColors,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarCubit, MonthCalendarState>(
      builder: (context, state) => BlocBuilder<ClockCubit, DateTime>(
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
                    onPressed: () async =>
                        context.read<MonthCalendarCubit>().goToPreviousMonth(),
                  )
                : null,
            showClock: showClock,
            clockReplacement: !currentMonth
                ? GoToTodayButton(
                    onPressed: () async =>
                        context.read<MonthCalendarCubit>().goToCurrentMonth(),
                  )
                : null,
            rightAction: showBrowseButtons
                ? RightNavButton(
                    onPressed: () async =>
                        context.read<MonthCalendarCubit>().goToNextMonth(),
                  )
                : null,
          );
        },
      ),
    );
  }
}
