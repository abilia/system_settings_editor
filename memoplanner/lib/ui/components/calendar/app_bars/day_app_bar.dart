import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leftAction;
  final Widget? rightAction;
  final Widget? clockReplacement;

  final DateTime day;

  const DayAppBar({
    required this.day,
    this.leftAction,
    this.rightAction,
    this.clockReplacement,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final appBarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.dayAppBar);
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
        translate: Lt.of(context),
        currentNight: isNight,
        dayPart: dayPart,
      ),
      rightAction: rightAction,
      leftAction: leftAction,
      crossedOver: day.isDayBefore(currentMinute),
      clockReplacement: clockReplacement,
      showClock: appBarSettings.showClock,
    );
  }
}
