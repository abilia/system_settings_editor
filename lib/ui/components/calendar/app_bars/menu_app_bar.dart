import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.largeHeight);

  @override
  Widget build(BuildContext context) {
    final memoSettingsState = context.watch<MemoplannerSettingBloc>().state;
    final appBarSettings = memoSettingsState.settings.appBar;
    final time = context.watch<ClockBloc>().state;

    if (appBarSettings.displayDayCalendarAppBar) {
      return CalendarAppBar(
        day: time,
        calendarDayColor: memoSettingsState.settings.calendar.dayColor,
        rows: AppBarTitleRows.day(
          displayWeekDay: appBarSettings.activityDisplayWeekDay,
          displayPartOfDay: appBarSettings.activityDisplayDayPeriod,
          displayDate: appBarSettings.activityDisplayDate,
          currentTime: time,
          day: time,
          dayPart: context.read<DayPartCubit>().state,
          dayParts: memoSettingsState.settings.calendar.dayParts,
          langCode: Localizations.localeOf(context).toLanguageTag(),
          translator: Translator.of(context).translate,
        ),
        showClock: appBarSettings.activityDisplayClock,
      );
    }
    return const SizedBox.shrink();
  }
}
