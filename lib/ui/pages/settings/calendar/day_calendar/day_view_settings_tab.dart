import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayViewSettingsTab extends StatelessWidget {
  const DayViewSettingsTab({Key? key}) : super(key: key);
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
                  AbiliaIcons.calendarList,
                  DayCalendarType.list,
                ),
                SelectorItem(
                  t.oneTimePillarView,
                  AbiliaIcons.timeline,
                  DayCalendarType.oneTimepillar,
                ),
                SelectorItem(
                  t.twoTimePillarsView,
                  AbiliaIcons.twoTimelines,
                  DayCalendarType.twoTimepillars,
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
                  AbiliaIcons.dayInterval,
                  TimepillarIntervalType.interval,
                ),
                SelectorItem(
                  t.viewDay,
                  AbiliaIcons.sun,
                  TimepillarIntervalType.day,
                ),
                SelectorItem(
                  t.dayAndNight,
                  AbiliaIcons.dayNight,
                  TimepillarIntervalType.dayAndNight,
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
                  AbiliaIcons.decreaseText,
                  TimepillarZoom.small,
                ),
                SelectorItem(
                  t.medium,
                  AbiliaIcons.decreaseText,
                  TimepillarZoom.normal,
                ),
                SelectorItem(
                  t.large,
                  AbiliaIcons.enlargeText,
                  TimepillarZoom.large,
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
