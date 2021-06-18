// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayViewSettingsTab extends StatelessWidget {
  const DayViewSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) {
        final cubit = context.read<DayCalendarSettingsCubit>();
        return SettingsTab(
          dividerPadding: 8.s,
          children: [
            Selector<DayCalendarType>(
              heading: t.viewMode,
              groupValue: state.calendarType,
              items: [
                SelectorItem(
                  t.listView,
                  AbiliaIcons.calendar_list,
                  DayCalendarType.LIST,
                ),
                SelectorItem(
                  t.timePillarView,
                  AbiliaIcons.timeline,
                  DayCalendarType.TIMEPILLAR,
                ),
              ],
              onChanged: (type) => cubit.changeDayCalendarSettings(
                  state.copyWith(calendarType: type)),
            ),
            Divider(endIndent: 16.s),
            Selector<TimepillarIntervalType>(
              heading: t.dayInterval,
              groupValue: state.dayInterval,
              items: [
                SelectorItem(
                  t.interval,
                  AbiliaIcons.day_interval,
                  TimepillarIntervalType.INTERVAL,
                ),
                SelectorItem(
                  t.viewDay,
                  AbiliaIcons.sun,
                  TimepillarIntervalType.DAY,
                ),
                SelectorItem(
                  t.dayAndNight,
                  AbiliaIcons.day_night,
                  TimepillarIntervalType.DAY_AND_NIGHT,
                ),
              ],
              onChanged: (newDayInterval) => cubit.changeDayCalendarSettings(
                  state.copyWith(dayInterval: newDayInterval)),
            ),
            Divider(endIndent: 16.s),
            Selector<TimepillarZoom>(
              heading: t.zoom,
              groupValue: state.timepillarZoom,
              items: [
                SelectorItem(
                  t.small,
                  AbiliaIcons.decrease_text,
                  TimepillarZoom.SMALL,
                ),
                SelectorItem(
                  t.medium,
                  AbiliaIcons.decrease_text,
                  TimepillarZoom.NORMAL,
                ),
                SelectorItem(
                  t.large,
                  AbiliaIcons.enlarge_text,
                  TimepillarZoom.LARGE,
                ),
              ],
              onChanged: (newZoom) => cubit.changeDayCalendarSettings(
                  state.copyWith(timepillarZoom: newZoom)),
            ),
            Divider(endIndent: 16.s),
            Selector<bool>(
              heading: t.activityDuration,
              groupValue: state.dotsInTimePillar,
              items: [
                SelectorItem(
                  t.dots,
                  AbiliaIcons.options,
                  true,
                ),
                SelectorItem(
                  t.edge,
                  AbiliaIcons.flarp,
                  false,
                ),
              ],
              onChanged: (dots) => cubit.changeDayCalendarSettings(
                  state.copyWith(dotsInTimePillar: dots)),
            ),
          ],
        );
      },
    );
  }
}
