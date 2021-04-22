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
            DuoSelector<DayCalendarType>(
              heading: t.viewMode,
              groupValue: state.calendarType,
              leftText: t.listView,
              rightText: t.timePillarView,
              leftValue: DayCalendarType.LIST,
              rightValue: DayCalendarType.TIMEPILLAR,
              leftIcon: AbiliaIcons.calendar_list,
              rightIcon: AbiliaIcons.timeline,
              onChanged: (type) => cubit.changeDayCalendarSettings(
                  state.copyWith(calendarType: type)),
            ),
            Divider(),
            TripleSelector<TimepillarIntervalType>(
              heading: t.dayInterval,
              groupValue: state.dayInterval,
              leftText: t.interval,
              midText: t.viewDay,
              rightText: t.dayAndNight,
              leftValue: TimepillarIntervalType.INTERVAL,
              midValue: TimepillarIntervalType.DAY,
              rightValue: TimepillarIntervalType.DAY_AND_NIGHT,
              leftIcon: AbiliaIcons.day_interval,
              midIcon: AbiliaIcons.sun,
              rightIcon: AbiliaIcons.day_night,
              onChanged: (newDayInterval) => cubit.changeDayCalendarSettings(
                  state.copyWith(dayInterval: newDayInterval)),
            ),
            Divider(),
            TripleSelector<TimepillarZoom>(
              heading: t.zoom,
              groupValue: state.timepillarZoom,
              leftText: t.small,
              midText: t.medium,
              rightText: t.large,
              leftValue: TimepillarZoom.SMALL,
              midValue: TimepillarZoom.NORMAL,
              rightValue: TimepillarZoom.LARGE,
              leftIcon: AbiliaIcons.decrease_text,
              midIcon: AbiliaIcons.decrease_text,
              rightIcon: AbiliaIcons.enlarge_text,
              onChanged: (newZoom) => cubit.changeDayCalendarSettings(
                  state.copyWith(timepillarZoom: newZoom)),
            ),
            Divider(),
            DuoSelector<bool>(
              heading: t.activityDuration,
              groupValue: state.dotsInTimePillar,
              leftText: t.dots,
              rightText: t.edge,
              leftValue: true,
              rightValue: false,
              leftIcon: AbiliaIcons.options,
              rightIcon: AbiliaIcons.flarp,
              onChanged: (dots) => cubit.changeDayCalendarSettings(
                  state.copyWith(dotsInTimePillar: dots)),
            ),
          ],
        );
      },
    );
  }
}
