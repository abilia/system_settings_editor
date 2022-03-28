import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EyeButtonSettingsTab extends StatelessWidget {
  const EyeButtonSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) => ListView(
        padding: EdgeInsets.only(
          top: layout.templates.m1.top,
          bottom: layout.templates.m1.bottom,
        ),
        children: [
          Tts(child: Text(t.viewSettings)).pad(m1Horizontal),
          CollapsableWidget(
            collapsed: !state.showTypeOfDisplay,
            child: _buildSelector(
              [
                SelectorItem(t.listView, AbiliaIcons.calendarList),
                SelectorItem(t.oneTimePillarView, AbiliaIcons.timeline),
                SelectorItem(t.twoTimePillarsView, AbiliaIcons.timeline),
              ],
            ),
          ),
          CollapsableWidget(
            collapsed: !state.showTimepillarLength,
            child: _buildSelector(
              [
                SelectorItem(t.interval, AbiliaIcons.dayInterval),
                SelectorItem(t.viewDay, AbiliaIcons.sun),
                SelectorItem(t.dayAndNight, AbiliaIcons.dayNight),
              ],
            ),
          ),
          CollapsableWidget(
            collapsed: !state.showTimelineZoom,
            child: _buildSelector(
              [
                SelectorItem(t.small, AbiliaIcons.decreaseText),
                SelectorItem(t.medium, AbiliaIcons.decreaseText),
                SelectorItem(t.large, AbiliaIcons.enlargeText),
              ],
            ),
          ),
          CollapsableWidget(
            collapsed: !state.showDurationSelection,
            child: _buildSelector(
              [
                SelectorItem(t.dots, AbiliaIcons.options),
                SelectorItem(t.edge, AbiliaIcons.flarp),
              ],
            ),
          ),
          SwitchField(
            key: TestKey.showTypeOfDisplaySwitch,
            value: state.showTypeOfDisplay,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTypeOfDisplay: v),
                  ),
            },
            child: Text(t.typeOfDisplay),
          ).pad(EdgeInsets.fromLTRB(
            layout.templates.m1.left,
            layout.formPadding.groupBottomDistance,
            layout.templates.m1.right,
            0,
          )),
          SwitchField(
            key: TestKey.showTimepillarLengthSwitch,
            value: state.showTimepillarLength,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTimepillarLength: v),
                  ),
            },
            child: Text(t.timelineLength),
          ).pad(m1ItemPadding),
          SwitchField(
            key: TestKey.showTimelineZoomSwitch,
            value: state.showTimelineZoom,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTimelineZoom: v),
                  ),
            },
            child: Text(t.zoom),
          ).pad(m1ItemPadding),
          SwitchField(
            key: TestKey.showDurationSelectionSwitch,
            value: state.showDurationSelection,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showDurationSelection: v),
                  ),
            },
            child: Text(t.activityDuration),
          ).pad(m1ItemPadding),
        ],
      ),
    );
  }

  Widget _buildSelector(List<SelectorItem> items) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: layout.templates.m1.left,
            right: layout.templates.m1.right,
            top: layout.formPadding.verticalItemDistance,
          ),
          child: Selector(
            groupValue: 0,
            items: items,
          ),
        ),
        Divider(
          height: layout.formPadding.groupBottomDistance,
        ),
      ],
    );
  }
}
