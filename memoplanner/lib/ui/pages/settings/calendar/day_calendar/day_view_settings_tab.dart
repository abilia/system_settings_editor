import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayViewSettingsTab extends StatelessWidget {
  const DayViewSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettings>(
      builder: (context, settings) {
        final dayCalendar = context.read<DayCalendarSettingsCubit>();
        return SettingsTab(
          dividerPadding: layout.formPadding.verticalItemDistance,
          children: [
            Selector<DayCalendarType>(
              heading: t.viewMode,
              groupValue: settings.viewOptions.calendarType,
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
              onChanged: (type) => dayCalendar.changeSettings(settings.copyWith(
                  viewOptions:
                      settings.viewOptions.copyWith(calendarType: type))),
            ),
            const Divider(),
            Selector<TimepillarIntervalType>(
              heading: t.dayInterval,
              groupValue: settings.viewOptions.intervalType,
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
              onChanged: (newDayInterval) => dayCalendar.changeSettings(
                  settings.copyWith(
                      viewOptions: settings.viewOptions
                          .copyWith(intervalType: newDayInterval))),
            ),
            const Divider(),
            Selector<TimepillarZoom>(
              heading: t.timelineZoom,
              groupValue: settings.viewOptions.timepillarZoom,
              items: [
                SelectorItem(
                  t.small,
                  AbiliaIcons.decreaseText,
                  TimepillarZoom.small,
                ),
                SelectorItem(
                  t.medium,
                  AbiliaIcons.mediumText,
                  TimepillarZoom.normal,
                ),
                SelectorItem(
                  t.large,
                  AbiliaIcons.enlargeText,
                  TimepillarZoom.large,
                ),
              ],
              onChanged: (newZoom) => dayCalendar.changeSettings(
                  settings.copyWith(
                      viewOptions: settings.viewOptions
                          .copyWith(timepillarZoom: newZoom))),
            ),
            const Divider(),
            Selector<bool>(
              heading: t.activityDuration,
              groupValue: settings.viewOptions.dots,
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
              onChanged: (dots) => dayCalendar.changeSettings(settings.copyWith(
                  viewOptions: settings.viewOptions.copyWith(dots: dots))),
            ),
          ],
        );
      },
    );
  }
}
