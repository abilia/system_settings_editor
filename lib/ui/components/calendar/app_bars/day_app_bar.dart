import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/day_parts.dart';
import 'package:seagull/models/settings/memoplanner_settings_enums.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leftAction;
  final Widget? rightAction;

  final DateTime day;

  const DayAppBar({
    Key? key,
    this.leftAction,
    this.rightAction,
    required this.day,
  }) : super(key: key);

  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
          return BlocBuilder<ClockBloc, DateTime>(
            builder: (context, time) =>
                BlocBuilder<TimepillarCubit, TimepillarState>(
              builder: (context, timePillarState) {
                bool currentNight = timePillarState.showNightCalendar &&
                    time.isAtSameDay(day) &&
                    time.dayPart(memoSettingsState.dayParts) == DayPart.night;
                return CalendarAppBar(
                  day: day,
                  calendarDayColor: currentNight
                      ? DayColor.noColors
                      : memoSettingsState.calendarDayColor,
                  rows: AppBarTitleRows.day(
                    displayWeekDay: memoSettingsState.activityDisplayWeekDay,
                    displayPartOfDay:
                        memoSettingsState.activityDisplayDayPeriod,
                    displayDate: memoSettingsState.activityDisplayDate,
                    currentTime: time,
                    day: day,
                    dayParts: memoSettingsState.dayParts,
                    langCode: Localizations.localeOf(context).toLanguageTag(),
                    translator: Translator.of(context).translate,
                    currentNight: currentNight,
                  ),
                  rightAction: rightAction,
                  leftAction: leftAction,
                  crossedOver: day.isDayBefore(time),
                  showClock: memoSettingsState.activityDisplayClock,
                );
              },
            ),
          );
        },
      );
}
