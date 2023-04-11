import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/models/all.dart';

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
    final currentMinute = context.watch<ClockBloc>().state;
    final dayPart = context.read<DayPartCubit>().state;
    final isNight = context.watch<NightMode>().state;

    return CalendarAppBar(
      day: day,
      calendarDayColor: isNight ? DayColor.noColors : calendarSettings.dayColor,
      rows: AppBarTitleRows.day(
        settings: appBarSettings,
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
