import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';

class DayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leftAction;
  final Widget? rightAction;

  final DateTime day;

  const DayAppBar({
    required this.day,
    this.leftAction,
    this.rightAction,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final memoSettingsState = context.watch<MemoplannerSettingBloc>().state;
    final calendarSettings = memoSettingsState.settings.calendar;
    final currentMinute = context.watch<ClockBloc>().state;
    final showNightCalendar = context.select<TimepillarCubit, bool>(
        (cubit) => cubit.state.showNightCalendar);
    bool isTimepillar =
        memoSettingsState.dayCalendarType != DayCalendarType.list;
    bool isNight = (!isTimepillar || showNightCalendar) &&
        currentMinute.isAtSameDay(day) &&
        currentMinute.dayPart(calendarSettings.dayParts) == DayPart.night;

    return CalendarAppBar(
      day: day,
      calendarDayColor: isNight ? DayColor.noColors : calendarSettings.dayColor,
      rows: AppBarTitleRows.day(
        displayWeekDay: memoSettingsState.activityDisplayWeekDay,
        displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
        displayDate: memoSettingsState.activityDisplayDate,
        currentTime: currentMinute,
        day: day,
        dayParts: calendarSettings.dayParts,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translator: Translator.of(context).translate,
        currentNight: isNight,
      ),
      rightAction: rightAction,
      leftAction: leftAction,
      crossedOver: day.isDayBefore(currentMinute),
      showClock: memoSettingsState.activityDisplayClock,
    );
  }
}
