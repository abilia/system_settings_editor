import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/day_parts.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.largeAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, time) =>
            BlocBuilder<TimepillarCubit, TimepillarState>(
          builder: (context, timePillarState) {
            bool currentNight = timePillarState.showNightCalendar &&
                time.dayPart(memoSettingsState.dayParts) == DayPart.night;
            return CalendarAppBar(
              day: time,
              calendarDayColor: memoSettingsState.calendarDayColor,
              rows: AppBarTitleRows.day(
                displayWeekDay: memoSettingsState.activityDisplayWeekDay,
                displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
                displayDate: memoSettingsState.activityDisplayDate,
                currentTime: time,
                day: time,
                dayParts: memoSettingsState.dayParts,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                translator: Translator.of(context).translate,
                currentNight: currentNight,
              ),
              showClock: memoSettingsState.activityDisplayClock,
            );
          },
        ),
      ),
    );
  }
}
