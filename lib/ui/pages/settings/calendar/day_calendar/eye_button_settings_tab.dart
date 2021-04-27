import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/calendar/day_calendar_settings/day_calendar_settings_cubit.dart';
import 'package:seagull/ui/all.dart';

class EyeButtonSettingsTab extends StatelessWidget {
  const EyeButtonSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        dividerPadding: 8.s,
        children: [
          Text(t.viewSettings),
          if (state.showTypeOfDisplay) ...[
            PreviewDuo(
              firstIcon: AbiliaIcons.calendar_list,
              firstTitle: t.listView,
              secondIcon: AbiliaIcons.timeline,
              secondTitle: t.timePillarView,
            ),
            Divider()
          ],
          if (state.showTimepillarLength) ...[
            PreviewTripple(
              firstIcon: AbiliaIcons.day_interval,
              firstTitle: t.interval,
              secondIcon: AbiliaIcons.sun,
              secondTitle: t.viewDay,
              thirdIcon: AbiliaIcons.day_night,
              thirdTitle: t.dayAndNight,
            ),
            Divider()
          ],
          if (state.showTimelineZoom) ...[
            PreviewTripple(
              firstIcon: AbiliaIcons.decrease_text,
              firstTitle: t.small,
              secondIcon: AbiliaIcons.decrease_text,
              secondTitle: t.medium,
              thirdIcon: AbiliaIcons.enlarge_text,
              thirdTitle: t.large,
            ),
            Divider()
          ],
          if (state.showDurationSelection) ...[
            PreviewDuo(
              firstIcon: AbiliaIcons.options,
              firstTitle: t.dots,
              secondIcon: AbiliaIcons.flarp,
              secondTitle: t.edge,
            ),
            Divider()
          ],
          SwitchField(
            key: TestKey.showTypeOfDisplaySwitch,
            text: Text(t.typeOfDisplay),
            value: state.showTypeOfDisplay,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTypeOfDisplay: v),
                  ),
            },
          ),
          SwitchField(
            key: TestKey.showTimepillarLengthSwitch,
            text: Text(t.timelineLength),
            value: state.showTimepillarLength,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTimepillarLength: v),
                  ),
            },
          ),
          SwitchField(
            key: TestKey.showTimelineZoomSwitch,
            text: Text(t.zoom),
            value: state.showTimelineZoom,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTimelineZoom: v),
                  ),
            },
          ),
          SwitchField(
            key: TestKey.showDurationSelectionSwitch,
            text: Text(t.activityDuration),
            value: state.showDurationSelection,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showDurationSelection: v),
                  ),
            },
          ),
        ],
      ),
    );
  }
}

class PreviewTripple extends StatelessWidget {
  final String firstTitle, secondTitle, thirdTitle;
  final IconData firstIcon, secondIcon, thirdIcon;
  const PreviewTripple({
    Key key,
    @required this.firstTitle,
    @required this.secondTitle,
    @required this.thirdTitle,
    @required this.firstIcon,
    @required this.secondIcon,
    @required this.thirdIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        Expanded(
          child: Tts(
            data: 'text',
            child: SelectButton(
              title: firstTitle,
              icon: firstIcon,
              borderRadius: borderRadiusLeft,
            ),
          ),
        ),
        SizedBox(
          width: 2.s,
        ),
        Expanded(
          child: SelectButton(
            title: secondTitle,
            icon: secondIcon,
            borderRadius: BorderRadius.zero,
          ),
        ),
        SizedBox(
          width: 2.s,
        ),
        Expanded(
          child: SelectButton(
            title: thirdTitle,
            icon: thirdIcon,
            borderRadius: borderRadiusRight,
          ),
        ),
      ]),
    );
  }
}

class PreviewDuo extends StatelessWidget {
  final String firstTitle, secondTitle;
  final IconData firstIcon, secondIcon;
  const PreviewDuo(
      {Key key,
      this.firstTitle,
      this.secondTitle,
      this.firstIcon,
      this.secondIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        Expanded(
          child: Tts(
            data: 'text',
            child: SelectButton(
              title: firstTitle,
              icon: firstIcon,
              borderRadius: borderRadiusLeft,
            ),
          ),
        ),
        SizedBox(
          width: 2.s,
        ),
        Expanded(
          child: SelectButton(
            title: secondTitle,
            icon: secondIcon,
            borderRadius: borderRadiusRight,
          ),
        ),
      ]),
    );
  }
}

class SelectButton extends StatelessWidget {
  final BorderRadius borderRadius;
  final String title;
  final IconData icon;
  const SelectButton({
    Key key,
    @required this.borderRadius,
    @required this.title,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {},
      style: tabButtonStyle(
        borderRadius: borderRadius,
        isSelected: false,
      ).copyWith(
        textStyle: MaterialStateProperty.all(abiliaTextTheme.subtitle2),
        padding: MaterialStateProperty.all(EdgeInsets.only(bottom: 8.0.s)),
      ),
      child: Column(
        children: [
          Text(title),
          Icon(icon),
        ],
      ),
    );
  }
}
