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
    final appBarSettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.dayCalendar.appBar);
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
    final isTimepillar = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.viewOptions.calendarType !=
        DayCalendarType.list);
    final currentMinute = context.watch<ClockBloc>().state;
    final dayPart = context.read<DayPartCubit>().state;
    final showNightCalendar = context.select<TimepillarCubit, bool>(
        (cubit) => cubit.state.showNightCalendar);
    final isNight = (!isTimepillar || showNightCalendar) &&
        currentMinute.isAtSameDay(day) &&
        dayPart.isNight;

    return CalendarAppBar(
      day: day,
      calendarDayColor: isNight ? DayColor.noColors : calendarSettings.dayColor,
      rows: AppBarTitleRows.day(
        displayWeekDay: appBarSettings.showDayPeriod,
        displayPartOfDay: appBarSettings.showWeekday,
        displayDate: appBarSettings.showDate,
        currentTime: currentMinute,
        day: day,
        dayParts: calendarSettings.dayParts,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translator: Translator.of(context).translate,
        currentNight: isNight,
        dayPart: dayPart,
      ),
      rightAction: rightAction,
      leftAction: leftAction,
      crossedOver: day.isDayBefore(currentMinute),
      showClock: appBarSettings.showClock,
    );
  }
}
