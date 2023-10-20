import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class DayViewSettingsTab extends StatelessWidget {
  const DayViewSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettings>(
      builder: (context, settings) {
        final dayCalendar = context.read<DayCalendarSettingsCubit>();
        return SettingsTab(
          dividerPadding: layout.formPadding.verticalItemDistance,
          children: [
            Selector<DayCalendarType>(
              heading: translate.viewMode,
              groupValue: settings.viewOptions.calendarType,
              items: [
                SelectorItem(
                  translate.listView,
                  AbiliaIcons.calendarList,
                  DayCalendarType.list,
                ),
                SelectorItem(
                  translate.oneTimePillarView,
                  AbiliaIcons.timeline,
                  DayCalendarType.oneTimepillar,
                ),
                SelectorItem(
                  translate.twoTimePillarsView,
                  AbiliaIcons.twoTimelines,
                  DayCalendarType.twoTimepillars,
                ),
              ],
              onChanged: (type) => dayCalendar.changeViewOptions(
                  settings.viewOptions.copyWith(calendarType: type)),
            ),
            const Divider(),
            Selector<TimepillarIntervalType>(
              heading: translate.dayInterval,
              groupValue: settings.viewOptions.intervalType,
              items: [
                SelectorItem(
                  translate.interval,
                  AbiliaIcons.dayInterval,
                  TimepillarIntervalType.interval,
                ),
                SelectorItem(
                  translate.viewDay,
                  AbiliaIcons.sun,
                  TimepillarIntervalType.day,
                ),
                SelectorItem(
                  translate.dayAndNight,
                  AbiliaIcons.dayNight,
                  TimepillarIntervalType.dayAndNight,
                ),
              ],
              onChanged: (newDayInterval) => dayCalendar.changeViewOptions(
                  settings.viewOptions.copyWith(intervalType: newDayInterval)),
            ),
            const Divider(),
            Selector<TimepillarZoom>(
              heading: translate.timelineZoom,
              groupValue: settings.viewOptions.timepillarZoom,
              items: [
                SelectorItem(
                  translate.small,
                  AbiliaIcons.decreaseText,
                  TimepillarZoom.small,
                ),
                SelectorItem(
                  translate.medium,
                  AbiliaIcons.mediumText,
                  TimepillarZoom.normal,
                ),
                SelectorItem(
                  translate.large,
                  AbiliaIcons.enlargeText,
                  TimepillarZoom.large,
                ),
              ],
              onChanged: (newZoom) => dayCalendar.changeViewOptions(
                  settings.viewOptions.copyWith(timepillarZoom: newZoom)),
            ),
            const Divider(),
            Selector<bool>(
              heading: translate.activityDuration,
              groupValue: settings.viewOptions.dots,
              items: [
                SelectorItem(
                  translate.dots,
                  AbiliaIcons.options,
                  true,
                ),
                SelectorItem(
                  translate.edge,
                  AbiliaIcons.flarp,
                  false,
                ),
              ],
              onChanged: (dots) => dayCalendar
                  .changeViewOptions(settings.viewOptions.copyWith(dots: dots)),
            ),
          ],
        );
      },
    );
  }
}
